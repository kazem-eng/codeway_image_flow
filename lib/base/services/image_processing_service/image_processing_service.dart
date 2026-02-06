import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pdf_widgets;

import '../../base_exception.dart';
import '../../../../features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'i_image_processing_service.dart';

/// Image processing using ML Kit (face + text) and image/pdf packages.
class ImageProcessingService implements IImageProcessingService {
  static const MethodChannel _nativeChannel = MethodChannel(
    'codeway_image_processing/native_image_processing',
  );

  // Document processing uses native pipelines on iOS/Android; faces stay in Dart.
  bool get _useNativeDoc => Platform.isIOS || Platform.isAndroid;

  @override
  Future<ProcessingType> detectContentType(Uint8List imageBytes) async {
    // Always use Dart/ML Kit for face vs document detection.
    // Native processing is reserved for document flow only.
    return _detectContentTypeDart(imageBytes);
  }

  Future<ProcessingType> _detectContentTypeDart(Uint8List imageBytes) async {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw ImageProcessingException(message: 'Failed to decode image');
      }
      // Normalize orientation before ML Kit analysis.
      final oriented = img.bakeOrientation(decoded);
      final orientedBytes = Uint8List.fromList(
        img.encodeJpg(oriented, quality: 90),
      );

      // First check for faces - if no faces detected, treat as document.
      final faces = await _detectFaces(orientedBytes);
      if (faces.isEmpty) {
        // No faces detected - check for text/document content.
        final blocks = await _detectTextBlocks(orientedBytes);
        if (blocks.isNotEmpty || _hasDocumentLikeFeatures(oriented)) {
          return ProcessingType.document;
        }
        // Default to document if no faces and unclear content.
        return ProcessingType.document;
      }

      // Faces detected - compare with text coverage to avoid false positives.
      final blocks = await _detectTextBlocks(orientedBytes);
      final imageArea = oriented.width * oriented.height.toDouble();
      final faceScore = _maxFaceAreaRatio(faces, imageArea);
      final textScore = _textBoundsAreaRatio(blocks, imageArea);

      if (faceScore >= 0.02 && faceScore > textScore * 1.2) {
        return ProcessingType.face;
      }
      if (textScore >= 0.03 || blocks.length >= 3) {
        return ProcessingType.document;
      }
      if (faces.isNotEmpty) {
        return ProcessingType.face;
      }
      return ProcessingType.document;
    } catch (e) {
      throw ImageProcessingException(message: e.toString());
    }
  }

  /// Check if image has document-like features (edges, structure)
  bool _hasDocumentLikeFeatures(img.Image image) {
    // Simple heuristic: use Sobel edges and count high-gradient pixels.
    // Documents tend to have more structured edges than photos.
    final grayscale = img.grayscale(image.clone());
    final edges = img.sobel(grayscale);

    // Count edge pixels (pixels with high gradient).
    int edgePixelCount = 0;
    final threshold = 50; // Tuned threshold.
    for (var y = 0; y < edges.height; y++) {
      for (var x = 0; x < edges.width; x++) {
        final pixel = edges.getPixel(x, y);
        final intensity = pixel.r; // Grayscale, so r=g=b
        if (intensity > threshold) {
          edgePixelCount++;
        }
      }
    }

    final edgeRatio = edgePixelCount / (edges.width * edges.height);
    // Documents typically have 5-15% edge pixels.
    return edgeRatio > 0.05;
  }

  double _maxFaceAreaRatio(List<Face> faces, double imageArea) {
    if (faces.isEmpty || imageArea <= 0) return 0;
    double maxArea = 0;
    for (final face in faces) {
      final rect = face.boundingBox;
      final area = rect.width * rect.height;
      if (area > maxArea) maxArea = area;
    }
    return maxArea / imageArea;
  }

  double _textBoundsAreaRatio(List<TextBlock> blocks, double imageArea) {
    if (blocks.isEmpty || imageArea <= 0) return 0;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = 0;
    double maxY = 0;
    for (final block in blocks) {
      final rect = block.boundingBox;
      minX = min(minX, rect.left);
      minY = min(minY, rect.top);
      maxX = max(maxX, rect.right);
      maxY = max(maxY, rect.bottom);
    }
    if (minX == double.infinity) return 0;
    final width = max(0.0, maxX - minX);
    final height = max(0.0, maxY - minY);
    final area = width * height;
    return area / imageArea;
  }

  Future<List<Face>> _detectFaces(Uint8List imageBytes) async {
    // ML Kit expects file paths, so write a temp file per call.
    final tempFile = await _writeTempImage(imageBytes);
    try {
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: true,
          enableLandmarks: false,
          enableClassification: false,
          enableTracking: false,
          minFaceSize: 0.08,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );
      try {
        final faces = await detector.processImage(inputImage);
        return faces;
      } finally {
        detector.close();
      }
    } finally {
      await tempFile.delete();
    }
  }

  Future<File> _writeTempImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/mlkit_temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<List<TextBlock>> _detectTextBlocks(Uint8List imageBytes) async {
    // ML Kit text recognition also works on file paths.
    final tempFile = await _writeTempImage(imageBytes);
    try {
      final recognizer = TextRecognizer();
      try {
        final inputImage = InputImage.fromFilePath(tempFile.path);
        final result = await recognizer.processImage(inputImage);
        return result.blocks;
      } finally {
        recognizer.close();
      }
    } finally {
      await tempFile.delete();
    }
  }

  @override
  Future<Uint8List> detectAndProcessFaces(Uint8List imageBytes) async {
    // Always use Dart/ML Kit for face processing to ensure
    // consistent behavior across camera/gallery sources.
    return _detectAndProcessFacesDart(imageBytes);
  }

  Future<Uint8List> _detectAndProcessFacesDart(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    // Normalize orientation before detection and pixel edits.
    final oriented = img.bakeOrientation(decoded);
    final orientedBytes = Uint8List.fromList(
      img.encodeJpg(oriented, quality: 90),
    );
    final faces = await _detectFaces(orientedBytes);
    if (faces.isEmpty) {
      throw FaceDetectionException(message: 'No faces detected');
    }

    // Apply grayscale only inside the face region(s).
    img.Image result = oriented.clone();
    final scaleX = oriented.width.toDouble();
    final scaleY = oriented.height.toDouble();
    for (final face in faces) {
      // Expand the bounding box slightly to avoid harsh edges.
      final rect = _expandRect(face.boundingBox, 0.12, 0.16);
      final left = (rect.left.clamp(0.0, scaleX)).toInt();
      final top = (rect.top.clamp(0.0, scaleY)).toInt();
      final width = (rect.width.clamp(1.0, scaleX - left)).toInt();
      final height = (rect.height.clamp(1.0, scaleY - top)).toInt();
      if (width <= 0 || height <= 0) continue;
      final crop = img.copyCrop(
        result,
        x: left,
        y: top,
        width: width,
        height: height,
      );
      // Prefer contour polygon when available; otherwise fallback to ellipse mask.
      final contour = face.contours[FaceContourType.face]?.points ?? [];
      final masked = contour.isNotEmpty
          ? _applyContourGrayscale(
              crop,
              _scalePolygon(
                contour
                    .map(
                      (p) => Point<double>(
                        p.x.toDouble() - left,
                        p.y.toDouble() - top,
                      ),
                    )
                    .toList(),
                1.02,
                crop.width.toDouble(),
                crop.height.toDouble(),
              ),
            )
          : _applyEllipseGrayscale(crop);
      result = img.compositeImage(result, masked, dstX: left, dstY: top);
    }
    return Uint8List.fromList(img.encodeJpg(result, quality: 90));
  }

  img.Image _applyContourGrayscale(
    img.Image faceCrop,
    List<Point<double>> polygon,
  ) {
    final w = faceCrop.width;
    final h = faceCrop.height;
    final output = faceCrop.clone();
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (!_pointInPolygon(x + 0.5, y + 0.5, polygon)) continue;
        final pixel = output.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final gray = ((r + g + b) / 3).round();
        output.setPixelRgba(x, y, gray, gray, gray, a);
      }
    }
    return output;
  }

  Rect _expandRect(Rect rect, double widthFactor, double heightFactor) {
    // Expand about the center so the crop includes hair/chin margins.
    final expandX = rect.width * widthFactor;
    final expandY = rect.height * heightFactor;
    return Rect.fromLTRB(
      rect.left - expandX / 2,
      rect.top - expandY / 2,
      rect.right + expandX / 2,
      rect.bottom + expandY / 2,
    );
  }

  List<Point<double>> _scalePolygon(
    List<Point<double>> polygon,
    double scale,
    double maxWidth,
    double maxHeight,
  ) {
    // Scale polygon around centroid and clamp to bounds.
    if (polygon.isEmpty || scale == 1.0) return polygon;
    double cx = 0;
    double cy = 0;
    for (final p in polygon) {
      cx += p.x;
      cy += p.y;
    }
    cx /= polygon.length;
    cy /= polygon.length;
    return polygon.map((p) {
      final nx = cx + (p.x - cx) * scale;
      final ny = cy + (p.y - cy) * scale;
      return Point<double>(
        nx.clamp(0.0, maxWidth - 1),
        ny.clamp(0.0, maxHeight - 1),
      );
    }).toList();
  }

  bool _pointInPolygon(double x, double y, List<Point<double>> polygon) {
    // Ray-casting point-in-polygon test.
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].x;
      final yi = polygon[i].y;
      final xj = polygon[j].x;
      final yj = polygon[j].y;
      final intersect =
          (yi > y) != (yj > y) &&
          x < ((xj - xi) * (y - yi)) / (yj - yi + 0.000001) + xi;
      if (intersect) inside = !inside;
    }
    return inside;
  }

  img.Image _applyEllipseGrayscale(img.Image faceCrop) {
    // Elliptical mask fallback when no contours are available.
    final w = faceCrop.width;
    final h = faceCrop.height;
    final cx = (w - 1) / 2.0;
    final cy = (h - 1) / 2.0;
    final rx = w / 2.0;
    final ry = h / 2.0;
    final output = faceCrop.clone();
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final dx = (x - cx) / rx;
        final dy = (y - cy) / ry;
        if (dx * dx + dy * dy > 1.0) continue;
        final pixel = output.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        final a = pixel.a;
        final gray = ((r + g + b) / 3).round();
        output.setPixelRgba(x, y, gray, gray, gray, a);
      }
    }
    return output;
  }

  @override
  Future<Uint8List> processDocument(Uint8List imageBytes) async {
    if (_useNativeDoc) {
      try {
        // Native pipeline handles edge detection + perspective correction.
        final processed = await _nativeChannel.invokeMethod<Uint8List>(
          'processDocument',
          imageBytes,
        );
        if (processed != null) return processed;
      } on PlatformException {
        // Fall back to Dart implementation
      }
    }
    return _processDocumentDart(imageBytes);
  }

  Future<Uint8List> _processDocumentDart(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    // Dart fallback: just fix orientation and pass the photo through.
    // The resulting PDF will show exactly the captured image.
    final oriented = img.bakeOrientation(decoded);
    return Uint8List.fromList(img.encodeJpg(oriented, quality: 92));
  }

  @override
  Future<Uint8List> createPdfFromImage(
    Uint8List imageBytes,
    String title,
  ) async {
    if (_useNativeDoc) {
      try {
        // Native PDF for single-page images to match platform rendering.
        final pdfBytes = await _nativeChannel.invokeMethod<Uint8List>(
          'createPdfFromImage',
          {'bytes': imageBytes, 'title': title},
        );
        if (pdfBytes != null) return pdfBytes;
      } on PlatformException {
        // Fall back to Dart implementation
      }
    }
    return _createPdfFromImageDart(imageBytes, title);
  }

  @override
  Future<Uint8List> createPdfFromImages(
    List<Uint8List> imageBytes,
    String title,
  ) async {
    if (imageBytes.isEmpty) {
      throw ImageProcessingException(message: 'No pages provided');
    }
    // Multi-page PDFs are built in Dart for deterministic output.
    return _createPdfFromImagesDart(imageBytes, title);
  }

  Future<Uint8List> _createPdfFromImageDart(
    Uint8List imageBytes,
    String title,
  ) async {
    final pdf = pdf_widgets.Document(title: title);
    final imageProvider = pdf_widgets.MemoryImage(imageBytes);

    // A4 page dimensions in points.
    final pageWidth = pdf_lib.PdfPageFormat.a4.width;
    final pageHeight = pdf_lib.PdfPageFormat.a4.height;

    pdf.addPage(
      pdf_widgets.Page(
        pageFormat: pdf_lib.PdfPageFormat.a4,
        margin: pdf_widgets.EdgeInsets.zero,
        build: (ctx) => pdf_widgets.Center(
          child: pdf_widgets.Image(
            imageProvider,
            fit: pdf_widgets.BoxFit.contain,
            width: pageWidth,
            height: pageHeight,
          ),
        ),
      ),
    );
    return Uint8List.fromList(await pdf.save());
  }

  Future<Uint8List> _createPdfFromImagesDart(
    List<Uint8List> imageBytes,
    String title,
  ) async {
    final pdf = pdf_widgets.Document(title: title);

    final pageFormat = pdf_lib.PdfPageFormat.a4;
    final pageWidth = pageFormat.width;
    final pageHeight = pageFormat.height;

    // Add one page per processed image.
    for (final bytes in imageBytes) {
      final imageProvider = pdf_widgets.MemoryImage(bytes);
      pdf.addPage(
        pdf_widgets.Page(
          pageFormat: pageFormat,
          margin: pdf_widgets.EdgeInsets.zero,
          build: (ctx) => pdf_widgets.Center(
            child: pdf_widgets.Image(
              imageProvider,
              fit: pdf_widgets.BoxFit.contain,
              width: pageWidth,
              height: pageHeight,
            ),
          ),
        ),
      );
    }
    return Uint8List.fromList(await pdf.save());
  }
}
