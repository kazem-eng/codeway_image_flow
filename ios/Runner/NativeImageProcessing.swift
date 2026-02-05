import Flutter
import UIKit
import MLKitTextRecognition
import MLKitVision
import Vision
import CoreImage

private enum NativeImageProcessingError: LocalizedError {
  case invalidImage
  case processingFailed

  var errorDescription: String? {
    switch self {
    case .invalidImage:
      return "Invalid image data"
    case .processingFailed:
      return "Image processing failed"
    }
  }
}

final class NativeImageProcessing {
  private let ciContext = CIContext()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "processDocument":
      guard let typedData = call.arguments as? FlutterStandardTypedData else {
        result(
          FlutterError(
            code: "invalid_args",
            message: "Expected raw image bytes",
            details: nil
          )
        )
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        let processed = self.processDocumentData(from: typedData.data)
        DispatchQueue.main.async {
          result(FlutterStandardTypedData(bytes: processed))
        }
      }

    case "createPdfFromImage":
      guard
        let args = call.arguments as? [String: Any],
        let typedData = args["bytes"] as? FlutterStandardTypedData,
        let title = args["title"] as? String
      else {
        result(
          FlutterError(
            code: "invalid_args",
            message: "Expected bytes and title",
            details: nil
          )
        )
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let image = try self.loadNormalizedImage(from: typedData.data)
          let pdfData = self.createPdfData(from: image, title: title)
          DispatchQueue.main.async {
            result(FlutterStandardTypedData(bytes: pdfData))
          }
        } catch {
          DispatchQueue.main.async {
            result(
              FlutterError(
                code: "native_pdf_error",
                message: error.localizedDescription,
                details: nil
              )
            )
          }
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadImage(from data: Data) throws -> UIImage {
    guard let image = UIImage(data: data) else {
      throw NativeImageProcessingError.invalidImage
    }
    return image
  }

  private func loadNormalizedImage(from data: Data) throws -> UIImage {
    return normalize(try loadImage(from: data))
  }

  private func normalize(_ image: UIImage) -> UIImage {
    if image.imageOrientation == .up && image.scale == 1 {
      return image
    }
    let format = UIGraphicsImageRendererFormat()
    format.scale = image.scale
    format.opaque = false
    let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: image.size))
    }
  }

  private func makeVisionImage(from image: UIImage) -> VisionImage {
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    return visionImage
  }

  private func detectTextBlocks(in image: UIImage) throws -> [TextBlock] {
    let options = TextRecognizerOptions()
    let recognizer = TextRecognizer.textRecognizer(options: options)
    let visionImage = makeVisionImage(from: image)
    let semaphore = DispatchSemaphore(value: 0)
    var output: [TextBlock] = []
    var outputError: Error?
    recognizer.process(visionImage) { text, error in
      output = text?.blocks ?? []
      outputError = error
      semaphore.signal()
    }
    semaphore.wait()
    if let error = outputError {
      throw error
    }
    return output
  }

  private func processDocumentData(from data: Data) -> Data {
    guard let image = UIImage(data: data) else {
      return data
    }
    let normalized = normalize(image)
    let processed = processDocumentImage(normalized)
    return processed.jpegData(compressionQuality: 0.92) ?? data
  }

  private func processDocumentImage(_ image: UIImage) -> UIImage {
    guard let ciImage = CIImage(image: image) else { return image }

    let blocks = (try? detectTextBlocks(in: image)) ?? []
    let rectangle = detectDocumentRectangle(in: ciImage)

    var workingImage = ciImage
    if let rectangle = rectangle,
       let corrected = applyPerspectiveCorrection(ciImage, rectangle: rectangle) {
      workingImage = corrected
    } else if let cropped = cropToTextBounds(ciImage, blocks: blocks) {
      workingImage = cropped
    }

    let enhanced = enhanceContrast(workingImage)
    guard let output = renderUIImage(from: enhanced) else { return image }
    return output
  }

  private func detectDocumentRectangle(in ciImage: CIImage) -> VNRectangleObservation? {
    let request = VNDetectRectanglesRequest()
    request.maximumObservations = 1
    request.minimumConfidence = 0.6
    request.minimumAspectRatio = 0.3
    request.minimumSize = 0.2
    request.quadratureTolerance = 45.0

    let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    do {
      try handler.perform([request])
      return request.results?.first as? VNRectangleObservation
    } catch {
      return nil
    }
  }

  private func applyPerspectiveCorrection(
    _ ciImage: CIImage,
    rectangle: VNRectangleObservation
  ) -> CIImage? {
    let size = ciImage.extent.size
    let topLeft = CGPoint(x: rectangle.topLeft.x * size.width, y: rectangle.topLeft.y * size.height)
    let topRight = CGPoint(x: rectangle.topRight.x * size.width, y: rectangle.topRight.y * size.height)
    let bottomLeft = CGPoint(
      x: rectangle.bottomLeft.x * size.width,
      y: rectangle.bottomLeft.y * size.height
    )
    let bottomRight = CGPoint(
      x: rectangle.bottomRight.x * size.width,
      y: rectangle.bottomRight.y * size.height
    )

    guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
    filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
    filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
    filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
    return filter.outputImage
  }

  private func cropToTextBounds(_ ciImage: CIImage, blocks: [TextBlock]) -> CIImage? {
    guard !blocks.isEmpty else { return nil }
    var minX = CGFloat.greatestFiniteMagnitude
    var minY = CGFloat.greatestFiniteMagnitude
    var maxX: CGFloat = 0
    var maxY: CGFloat = 0

    for block in blocks {
      let rect = block.frame
      minX = min(minX, rect.minX)
      minY = min(minY, rect.minY)
      maxX = max(maxX, rect.maxX)
      maxY = max(maxY, rect.maxY)
    }

    if minX == CGFloat.greatestFiniteMagnitude { return nil }
    var rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    let paddingX = rect.width * 0.05
    let paddingY = rect.height * 0.05
    rect = rect.insetBy(dx: -paddingX, dy: -paddingY)

    let imageHeight = ciImage.extent.height
    let converted = CGRect(
      x: rect.origin.x,
      y: imageHeight - rect.origin.y - rect.height,
      width: rect.width,
      height: rect.height
    )
    let clamped = converted.intersection(ciImage.extent)
    if clamped.isEmpty { return nil }
    return ciImage.cropped(to: clamped)
  }

  private func enhanceContrast(_ ciImage: CIImage) -> CIImage {
    guard let filter = CIFilter(name: "CIColorControls") else { return ciImage }
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    filter.setValue(1.25, forKey: kCIInputContrastKey)
    filter.setValue(0.03, forKey: kCIInputBrightnessKey)
    filter.setValue(0.0, forKey: kCIInputSaturationKey)
    return filter.outputImage ?? ciImage
  }

  private func renderUIImage(from ciImage: CIImage) -> UIImage? {
    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    return UIImage(cgImage: cgImage, scale: 1, orientation: .up)
  }

  private func createPdfData(from image: UIImage, title: String) -> Data {
    let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = [
      kCGPDFContextTitle as String: title,
      kCGPDFContextCreator as String: "codeway_image_processing"
    ]
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

    return renderer.pdfData { context in
      context.beginPage()
      let imageSize = image.size
      let pageRatio = pageRect.width / pageRect.height
      let imageRatio = imageSize.width / imageSize.height

      var drawRect = pageRect
      if imageRatio > pageRatio {
        let height = pageRect.width / imageRatio
        drawRect.origin.y = (pageRect.height - height) * 0.5
        drawRect.size.height = height
      } else {
        let width = pageRect.height * imageRatio
        drawRect.origin.x = (pageRect.width - width) * 0.5
        drawRect.size.width = width
      }
      image.draw(in: drawRect)
    }
  }
}
