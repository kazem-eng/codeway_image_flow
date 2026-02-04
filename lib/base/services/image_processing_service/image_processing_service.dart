import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

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
  @override
  Future<ProcessingType> detectContentType(Uint8List imageBytes) async {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw ImageProcessingException(message: 'Failed to decode image');
      }
      final oriented = img.bakeOrientation(decoded);
      final orientedBytes = Uint8List.fromList(
        img.encodeJpg(oriented, quality: 90),
      );
      final faces = await _detectFaces(orientedBytes);
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
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    final oriented = img.bakeOrientation(decoded);
    final orientedBytes = Uint8List.fromList(
      img.encodeJpg(oriented, quality: 90),
    );
    final faces = await _detectFaces(orientedBytes);
    if (faces.isEmpty) {
      throw FaceDetectionException(message: 'No faces detected');
    }

    img.Image result = oriented.clone();
    final scaleX = oriented.width.toDouble();
    final scaleY = oriented.height.toDouble();
    for (final face in faces) {
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
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    final oriented = img.bakeOrientation(decoded);
    final orientedBytes = Uint8List.fromList(
      img.encodeJpg(oriented, quality: 92),
    );

    // Detect text blocks to find document boundaries
    final blocks = await _detectTextBlocks(orientedBytes);

    if (blocks.isEmpty) {
      // No text detected - return original image
      return orientedBytes;
    }

    // Calculate bounding box of all text blocks
    final bounds = _calculateTextBounds(
      blocks,
      oriented.width,
      oriented.height,
    );
    if (bounds == null) {
      // Invalid bounds - return original image
      return orientedBytes;
    }

    // Crop to document area with padding
    final padding = 20;
    final cropX = max(0, bounds.left.toInt() - padding);
    final cropY = max(0, bounds.top.toInt() - padding);
    final cropWidth = min(
      oriented.width - cropX,
      (bounds.right - bounds.left).toInt() + (padding * 2),
    );
    final cropHeight = min(
      oriented.height - cropY,
      (bounds.bottom - bounds.top).toInt() + (padding * 2),
    );

    if (cropWidth <= 0 || cropHeight <= 0) {
      return orientedBytes;
    }

    // Crop the image
    final cropped = img.copyCrop(
      oriented,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Enhance contrast and brightness for better readability
    final enhanced = img.adjustColor(cropped, contrast: 1.15, brightness: 0.02);

    return Uint8List.fromList(img.encodeJpg(enhanced, quality: 92));
  }

  Rect? _calculateTextBounds(
    List<TextBlock> blocks,
    int imageWidth,
    int imageHeight,
  ) {
    if (blocks.isEmpty) return null;

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

    if (minX == double.infinity) return null;

    // Clamp to image bounds
    minX = minX.clamp(0.0, imageWidth.toDouble());
    minY = minY.clamp(0.0, imageHeight.toDouble());
    maxX = maxX.clamp(0.0, imageWidth.toDouble());
    maxY = maxY.clamp(0.0, imageHeight.toDouble());

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  Future<Uint8List> createPdfFromImage(
    Uint8List imageBytes,
    String title,
  ) async {
    final pdf = pdf_widgets.Document();
    final imageProvider = pdf_widgets.MemoryImage(imageBytes);

    // A4 page dimensions in points
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
}
