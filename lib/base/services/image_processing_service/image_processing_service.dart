import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' as pdf_lib;
import 'package:pdf/widgets.dart' as pdf_widgets;

import 'package:codeway_image_processing/base/base_exception.dart';
import 'package:codeway_image_processing/base/services/method_channel_service/i_method_channel_service.dart';
import 'package:codeway_image_processing/base/services/method_channel_service/method_channel_service.dart';
import 'package:codeway_image_processing/features/image_processing/domain/entities/processed_image/processing_type.dart';
import 'i_image_processing_service.dart';

/// Channel name for native document/PDF processing on iOS/Android.
const String kNativeImageProcessingChannelName =
    'codeway_image_processing/native_image_processing';

/// Image processing using ML Kit (face + text) and image/pdf packages.
class ImageProcessingService implements IImageProcessingService {
  ImageProcessingService({IMethodChannelService? channelService})
    : _channelService = channelService ??
        MethodChannelService(channelName: kNativeImageProcessingChannelName);

  final IMethodChannelService _channelService;

  // JPEG encoding quality (0–100)
  static const int _jpegQualityDefault = 90;
  static const int _jpegQualityDocumentFallback = 92;

  // Face vs document detection thresholds
  static const double _minFaceAreaRatioForFace = 0.02;
  static const double _faceToTextRatioForFace = 1.2;
  static const double _minTextAreaRatioForDocument = 0.03;
  static const int _minTextBlocksForDocument = 3;

  // Document heuristic: Sobel edge density (> this ratio = document-like)
  static const double _edgeRatioThresholdForDocument = 0.05;
  static const int _edgeIntensityThreshold = 50;

  // Face region: expand bbox by these factors (width, height) to include hair/chin
  static const double _faceRectExpandWidthFactor = 0.12;
  static const double _faceRectExpandHeightFactor = 0.16;
  static const double _contourScaleFactor = 1.02;

  // ML Kit face detector
  static const double _minFaceSizeForDetection = 0.08;

  // Numerical stability (avoid div-by-zero in point-in-polygon)
  static const double _epsilon = 1e-6;

  /// True on iOS/Android; document processing may use native pipeline; face detection stays in Dart.
  bool get _useNativeDoc => Platform.isIOS || Platform.isAndroid;

  @override
  Future<ProcessingType> detectContentType(Uint8List imageBytes) async {
    return _detectContentTypeDart(imageBytes);
  }

  Future<ProcessingType> _detectContentTypeDart(Uint8List imageBytes) async {
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        throw ImageProcessingException(message: 'Failed to decode image');
      }
      final oriented = img.bakeOrientation(decoded);
      final orientedBytes = Uint8List.fromList(
        img.encodeJpg(oriented, quality: _jpegQualityDefault),
      );

      final faces = await _detectFaces(orientedBytes);
      if (faces.isEmpty) {
        final blocks = await _detectTextBlocks(orientedBytes);
        if (blocks.isNotEmpty || _hasDocumentLikeFeatures(oriented)) {
          return ProcessingType.document;
        }
        return ProcessingType.document;
      }

      final blocks = await _detectTextBlocks(orientedBytes);
      final imageArea = oriented.width * oriented.height.toDouble();
      final faceScore = _maxFaceAreaRatio(faces, imageArea);
      final textScore = _textBoundsAreaRatio(blocks, imageArea);

      if (faceScore >= _minFaceAreaRatioForFace &&
          faceScore > textScore * _faceToTextRatioForFace) {
        return ProcessingType.face;
      }
      if (textScore >= _minTextAreaRatioForDocument ||
          blocks.length >= _minTextBlocksForDocument) {
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

  /// Heuristic: Sobel edge density; documents usually have more structured edges than photos (>5%).
  bool _hasDocumentLikeFeatures(img.Image image) {
    final grayscale = img.grayscale(image.clone());
    final edges = img.sobel(grayscale);
    int edgePixelCount = 0;
    for (var y = 0; y < edges.height; y++) {
      for (var x = 0; x < edges.width; x++) {
        final pixel = edges.getPixel(x, y);
        final intensity = pixel.r;
        if (intensity > _edgeIntensityThreshold) {
          edgePixelCount++;
        }
      }
    }

    final edgeRatio = edgePixelCount / (edges.width * edges.height);
    return edgeRatio > _edgeRatioThresholdForDocument;
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
          minFaceSize: _minFaceSizeForDetection,
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
    return _detectAndProcessFacesDart(imageBytes);
  }

  Future<Uint8List> _detectAndProcessFacesDart(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    final oriented = img.bakeOrientation(decoded);
    final orientedBytes = Uint8List.fromList(
      img.encodeJpg(oriented, quality: _jpegQualityDefault),
    );
    final faces = await _detectFaces(orientedBytes);
    if (faces.isEmpty) {
      throw FaceDetectionException(message: 'No faces detected');
    }

    img.Image result = oriented.clone();
    final scaleX = oriented.width.toDouble();
    final scaleY = oriented.height.toDouble();
    for (final face in faces) {
      final rect = _expandRect(
        face.boundingBox,
        _faceRectExpandWidthFactor,
        _faceRectExpandHeightFactor,
      );
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
                  _contourScaleFactor,
                  crop.width.toDouble(),
                  crop.height.toDouble(),
                ),
            )
          : _applyEllipseGrayscale(crop);
      result = img.compositeImage(result, masked, dstX: left, dstY: top);
    }
    return Uint8List.fromList(img.encodeJpg(result, quality: _jpegQualityDefault));
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

  /// Expands rect about center (e.g. to include hair/chin in face crop).
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

  /// Ray-casting point-in-polygon test.
  bool _pointInPolygon(double x, double y, List<Point<double>> polygon) {
    var inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].x;
      final yi = polygon[i].y;
      final xj = polygon[j].x;
      final yj = polygon[j].y;
      final intersect =
          (yi > y) != (yj > y) &&
          x < ((xj - xi) * (y - yi)) / (yj - yi + _epsilon) + xi;
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Ellipse mask when face contour is unavailable.
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
    if (_useNativeDoc) {
      final processed = await _channelService.processDocument(imageBytes);
      if (processed != null) return processed;
    }
    return _processDocumentDart(imageBytes);
  }

  /// Dart fallback when native document processing is unavailable.
  Future<Uint8List> _processDocumentDart(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw ImageProcessingException(message: 'Failed to decode image');
    }
    final oriented = img.bakeOrientation(decoded);
    return Uint8List.fromList(
      img.encodeJpg(oriented, quality: _jpegQualityDocumentFallback),
    );
  }

  @override
  Future<Uint8List> createPdfFromImage(
    Uint8List imageBytes,
    String title,
  ) async {
    if (_useNativeDoc) {
      final pdfBytes = await _channelService.createPdfFromImage(
        imageBytes,
        title,
      );
      if (pdfBytes != null) return pdfBytes;
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
    return _createPdfFromImagesDart(imageBytes, title);
  }

  Future<Uint8List> _createPdfFromImageDart(
    Uint8List imageBytes,
    String title,
  ) async {
    final pdf = pdf_widgets.Document(title: title);
    final imageProvider = pdf_widgets.MemoryImage(imageBytes);
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
