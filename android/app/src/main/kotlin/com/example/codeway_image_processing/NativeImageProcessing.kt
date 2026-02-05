package com.example.codeway_image_processing

import android.graphics.*
import android.graphics.pdf.PdfDocument
import android.os.Handler
import android.os.Looper
import androidx.exifinterface.media.ExifInterface
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.opencv.android.OpenCVLoader
import org.opencv.android.Utils
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.core.Point as CvPoint
import org.opencv.core.Size
import org.opencv.imgproc.Imgproc
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sqrt

class NativeImageProcessing {
    private val detectionMaxDimension = 1280
    private val mainHandler = Handler(Looper.getMainLooper())
    private val openCvReady by lazy { OpenCVLoader.initDebug() }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "processDocument" -> {
                val bytes = call.arguments as? ByteArray
                if (bytes == null) {
                    result.error("invalid_args", "Expected raw image bytes", null)
                    return
                }
                Thread {
                    try {
                        val processed = processDocumentData(bytes)
                        mainHandler.post { result.success(processed) }
                    } catch (e: Exception) {
                        mainHandler.post {
                            result.error("native_processing_error", e.message, null)
                        }
                    }
                }.start()
            }

            "createPdfFromImage" -> {
                val args = call.arguments as? Map<*, *>
                val bytes = args?.get("bytes") as? ByteArray
                val title = args?.get("title") as? String
                if (bytes == null || title == null) {
                    result.error("invalid_args", "Expected bytes and title", null)
                    return
                }
                Thread {
                    try {
                        val bitmap = loadNormalizedBitmap(bytes) ?: run {
                            mainHandler.post {
                                result.error("native_pdf_error", "Invalid image data", null)
                            }
                            return@Thread
                        }
                        val pdfBytes = createPdfData(bitmap, title)
                        mainHandler.post { result.success(pdfBytes) }
                    } catch (e: Exception) {
                        mainHandler.post {
                            result.error("native_pdf_error", e.message, null)
                        }
                    }
                }.start()
            }

            else -> result.notImplemented()
        }
    }

    private fun loadNormalizedBitmap(bytes: ByteArray): Bitmap? {
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return null
        val oriented = applyExifOrientation(bytes, bitmap)
        return oriented.copy(Bitmap.Config.ARGB_8888, true)
    }

    private fun applyExifOrientation(bytes: ByteArray, bitmap: Bitmap): Bitmap {
        val exif = try {
            ExifInterface(ByteArrayInputStream(bytes))
        } catch (e: Exception) {
            return bitmap
        }
        val orientation = exif.getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL
        )
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.preScale(-1f, 1f)
                matrix.postRotate(90f)
            }
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.preScale(-1f, 1f)
                matrix.postRotate(270f)
            }
        }
        if (matrix.isIdentity) return bitmap
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    private fun processDocumentData(bytes: ByteArray): ByteArray {
        val bitmap = loadNormalizedBitmap(bytes) ?: return bytes
        val processed = processDocumentBitmap(bitmap)
        val stream = ByteArrayOutputStream()
        processed.compress(Bitmap.CompressFormat.JPEG, 92, stream)
        return stream.toByteArray()
    }

    private fun processDocumentBitmap(bitmap: Bitmap): Bitmap {
        val textBlocks = runCatching { detectTextBlocks(bitmap) }.getOrDefault(emptyList())
        val textBounds = computeTextBoundsRect(textBlocks, bitmap.width, bitmap.height)
        val corners = detectDocumentCornersOpenCV(bitmap, textBounds)
        val candidate = corners?.let { warpPerspectiveOpenCV(bitmap, it) }
        val fallback = candidate ?: textBounds?.let { cropBitmap(bitmap, it) } ?: bitmap
        return enhanceContrast(fallback)
    }

    private fun detectTextBlocks(bitmap: Bitmap): List<android.graphics.Rect> {
        val image = InputImage.fromBitmap(bitmap, 0)
        val recognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
        val result = Tasks.await(recognizer.process(image))
        return result.textBlocks.mapNotNull { it.boundingBox }
    }

    private data class CornerPoints(
        val topLeft: PointF,
        val topRight: PointF,
        val bottomRight: PointF,
        val bottomLeft: PointF
    )

    private data class DetectionBitmap(
        val bitmap: Bitmap,
        val scaleX: Float,
        val scaleY: Float
    )

    private fun resizeForDetection(bitmap: Bitmap): DetectionBitmap? {
        val maxDimension = max(bitmap.width, bitmap.height)
        if (maxDimension <= detectionMaxDimension) return null
        val scale = detectionMaxDimension.toFloat() / maxDimension.toFloat()
        val newWidth = (bitmap.width * scale).roundToInt().coerceAtLeast(1)
        val newHeight = (bitmap.height * scale).roundToInt().coerceAtLeast(1)
        val resized = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
        val scaleX = bitmap.width.toFloat() / newWidth.toFloat()
        val scaleY = bitmap.height.toFloat() / newHeight.toFloat()
        return DetectionBitmap(resized, scaleX, scaleY)
    }

    private fun detectDocumentCornersOpenCV(
        bitmap: Bitmap,
        textRect: Rect?
    ): CornerPoints? {
        if (!openCvReady) return null
        val detection = resizeForDetection(bitmap)
        val source = detection?.bitmap ?: bitmap
        val scaleX = detection?.scaleX ?: 1f
        val scaleY = detection?.scaleY ?: 1f

        val mat = Mat()
        val gray = Mat()
        val blurred = Mat()
        val edges = Mat()
        val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(5.0, 5.0))
        var bestQuad: MatOfPoint2f? = null

        try {
            Utils.bitmapToMat(source, mat)
            Imgproc.cvtColor(mat, gray, Imgproc.COLOR_RGBA2GRAY)
            Imgproc.GaussianBlur(gray, blurred, Size(5.0, 5.0), 0.0)
            Imgproc.Canny(blurred, edges, 75.0, 200.0)
            Imgproc.morphologyEx(edges, edges, Imgproc.MORPH_CLOSE, kernel)

            val contours = ArrayList<MatOfPoint>()
            Imgproc.findContours(edges, contours, Mat(), Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_SIMPLE)

            val imageArea = mat.width().toDouble() * mat.height().toDouble()
            val minArea = imageArea * 0.2
            val textCenter = textRect?.let {
                CvPoint(
                    (it.left + it.right) / 2.0 / scaleX,
                    (it.top + it.bottom) / 2.0 / scaleY
                )
            }

            bestQuad = findBestQuad(contours, minArea, textCenter)

            if (bestQuad == null) {
                val threshold = Mat()
                try {
                    Imgproc.adaptiveThreshold(
                        gray,
                        threshold,
                        255.0,
                        Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C,
                        Imgproc.THRESH_BINARY,
                        11,
                        2.0
                    )
                    Core.bitwise_not(threshold, threshold)
                    val altContours = ArrayList<MatOfPoint>()
                    Imgproc.findContours(
                        threshold,
                        altContours,
                        Mat(),
                        Imgproc.RETR_LIST,
                        Imgproc.CHAIN_APPROX_SIMPLE
                    )
                    bestQuad = findBestQuad(altContours, minArea, textCenter)
                } finally {
                    threshold.release()
                }
            }

            val result = bestQuad?.let { toCornerPoints(it, scaleX, scaleY) }
            bestQuad?.release()
            return result
        } finally {
            mat.release()
            gray.release()
            blurred.release()
            edges.release()
            kernel.release()
        }
    }

    private fun findBestQuad(
        contours: List<MatOfPoint>,
        minArea: Double,
        textCenter: CvPoint?
    ): MatOfPoint2f? {
        var best: MatOfPoint2f? = null
        var bestArea = 0.0

        for (contour in contours) {
            val contour2f = MatOfPoint2f(*contour.toArray())
            val perimeter = Imgproc.arcLength(contour2f, true)
            val approx = MatOfPoint2f()
            Imgproc.approxPolyDP(contour2f, approx, 0.02 * perimeter, true)
            contour2f.release()

            if (approx.total() != 4L) {
                approx.release()
                continue
            }

            val area = abs(Imgproc.contourArea(approx))
            if (area < minArea) {
                approx.release()
                continue
            }

            val approxPoints = approx.toArray()
            val approxInt = MatOfPoint(*approxPoints)
            val bounding = Imgproc.boundingRect(approxInt)
            val ratio = min(bounding.width, bounding.height).toDouble() /
                max(bounding.width, bounding.height).toDouble()
            val isConvex = Imgproc.isContourConvex(approxInt)
            approxInt.release()

            if (ratio < 0.3 || !isConvex) {
                approx.release()
                continue
            }

            if (textCenter != null && Imgproc.pointPolygonTest(approx, textCenter, false) < 0) {
                approx.release()
                continue
            }

            if (area > bestArea) {
                best?.release()
                best = approx
                bestArea = area
            } else {
                approx.release()
            }
        }

        if (best != null) return best

        var bestFallback: MatOfPoint2f? = null
        var bestFallbackArea = 0.0
        for (contour in contours) {
            val area = abs(Imgproc.contourArea(contour))
            if (area < minArea * 0.5) continue
            if (area < bestFallbackArea) continue

            val rect = Imgproc.minAreaRect(MatOfPoint2f(*contour.toArray()))
            val points = arrayOf(CvPoint(), CvPoint(), CvPoint(), CvPoint())
            rect.points(points)
            val quad = MatOfPoint2f(*points)

            if (textCenter != null && Imgproc.pointPolygonTest(quad, textCenter, false) < 0) {
                quad.release()
                continue
            }

            bestFallback?.release()
            bestFallback = quad
            bestFallbackArea = area
        }
        return bestFallback
    }

    private fun toCornerPoints(
        quad: MatOfPoint2f,
        scaleX: Float,
        scaleY: Float
    ): CornerPoints? {
        val points = quad.toArray()
        if (points.size != 4) return null
        val scaled = points.map { PointF((it.x * scaleX).toFloat(), (it.y * scaleY).toFloat()) }
        return orderCorners(scaled)
    }

    private fun orderCorners(points: List<PointF>): CornerPoints {
        val topLeft = points.minByOrNull { it.x + it.y } ?: points.first()
        val bottomRight = points.maxByOrNull { it.x + it.y } ?: points.last()
        val topRight = points.maxByOrNull { it.x - it.y } ?: points.first()
        val bottomLeft = points.minByOrNull { it.x - it.y } ?: points.last()
        return CornerPoints(topLeft, topRight, bottomRight, bottomLeft)
    }

    private fun warpPerspectiveOpenCV(bitmap: Bitmap, corners: CornerPoints): Bitmap? {
        if (!openCvReady) return null
        val widthA = distance(corners.bottomRight, corners.bottomLeft)
        val widthB = distance(corners.topRight, corners.topLeft)
        val maxWidth = max(widthA, widthB).roundToInt().coerceAtLeast(1)

        val heightA = distance(corners.topRight, corners.bottomRight)
        val heightB = distance(corners.topLeft, corners.bottomLeft)
        val maxHeight = max(heightA, heightB).roundToInt().coerceAtLeast(1)

        val src = MatOfPoint2f(
            CvPoint(corners.topLeft.x.toDouble(), corners.topLeft.y.toDouble()),
            CvPoint(corners.topRight.x.toDouble(), corners.topRight.y.toDouble()),
            CvPoint(corners.bottomRight.x.toDouble(), corners.bottomRight.y.toDouble()),
            CvPoint(corners.bottomLeft.x.toDouble(), corners.bottomLeft.y.toDouble())
        )
        val dst = MatOfPoint2f(
            CvPoint(0.0, 0.0),
            CvPoint(maxWidth.toDouble(), 0.0),
            CvPoint(maxWidth.toDouble(), maxHeight.toDouble()),
            CvPoint(0.0, maxHeight.toDouble())
        )

        val srcMat = Mat()
        val warped = Mat()
        val transform = Imgproc.getPerspectiveTransform(src, dst)
        return try {
            Utils.bitmapToMat(bitmap, srcMat)
            Imgproc.warpPerspective(
                srcMat,
                warped,
                transform,
                Size(maxWidth.toDouble(), maxHeight.toDouble()),
                Imgproc.INTER_LINEAR,
                Core.BORDER_REPLICATE
            )
            val output = Bitmap.createBitmap(maxWidth, maxHeight, Bitmap.Config.ARGB_8888)
            Utils.matToBitmap(warped, output)
            output
        } finally {
            src.release()
            dst.release()
            srcMat.release()
            warped.release()
            transform.release()
        }
    }

    private fun distance(p1: PointF, p2: PointF): Float {
        val dx = p1.x - p2.x
        val dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }

    private fun cropBitmap(bitmap: Bitmap, rect: Rect): Bitmap? {
        val left = rect.left.coerceAtLeast(0)
        val top = rect.top.coerceAtLeast(0)
        val right = rect.right.coerceAtMost(bitmap.width)
        val bottom = rect.bottom.coerceAtMost(bitmap.height)
        val width = (right - left).coerceAtLeast(1)
        val height = (bottom - top).coerceAtLeast(1)
        if (width <= 1 || height <= 1) return null
        return Bitmap.createBitmap(bitmap, left, top, width, height)
    }

    private fun computeTextBoundsRect(
        blocks: List<Rect>,
        imageWidth: Int,
        imageHeight: Int
    ): Rect? {
        if (blocks.isEmpty()) return null
        var minX = Int.MAX_VALUE
        var minY = Int.MAX_VALUE
        var maxX = 0
        var maxY = 0
        for (rect in blocks) {
            minX = min(minX, rect.left)
            minY = min(minY, rect.top)
            maxX = max(maxX, rect.right)
            maxY = max(maxY, rect.bottom)
        }
        if (minX == Int.MAX_VALUE) return null
        val width = (maxX - minX).coerceAtLeast(1)
        val height = (maxY - minY).coerceAtLeast(1)
        val paddingX = (width * 0.05f).roundToInt()
        val paddingY = (height * 0.05f).roundToInt()

        return Rect(
            (minX - paddingX).coerceAtLeast(0),
            (minY - paddingY).coerceAtLeast(0),
            (maxX + paddingX).coerceAtMost(imageWidth),
            (maxY + paddingY).coerceAtMost(imageHeight)
        )
    }

    private fun enhanceContrast(bitmap: Bitmap): Bitmap {
        val output = Bitmap.createBitmap(bitmap.width, bitmap.height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val paint = Paint(Paint.FILTER_BITMAP_FLAG)

        val saturation = ColorMatrix()
        saturation.setSaturation(0f)

        val contrast = 1.25f
        val brightness = 0.03f * 255f
        val translate = (-0.5f * contrast + 0.5f) * 255f + brightness
        val contrastMatrix = ColorMatrix(
            floatArrayOf(
                contrast, 0f, 0f, 0f, translate,
                0f, contrast, 0f, 0f, translate,
                0f, 0f, contrast, 0f, translate,
                0f, 0f, 0f, 1f, 0f
            )
        )
        saturation.postConcat(contrastMatrix)
        paint.colorFilter = ColorMatrixColorFilter(saturation)
        canvas.drawBitmap(bitmap, 0f, 0f, paint)
        return output
    }

    private fun createPdfData(bitmap: Bitmap, title: String): ByteArray {
        val pageWidth = 595
        val pageHeight = 842
        val document = PdfDocument()
        val pageInfo = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, 1).create()
        val page = document.startPage(pageInfo)

        val canvas = page.canvas
        val paint = Paint(Paint.FILTER_BITMAP_FLAG)

        val imageRect = fitRect(bitmap.width.toFloat(), bitmap.height.toFloat(), pageWidth.toFloat(), pageHeight.toFloat())
        canvas.drawBitmap(bitmap, null, imageRect, paint)

        document.finishPage(page)
        val out = ByteArrayOutputStream()
        document.writeTo(out)
        document.close()
        return out.toByteArray()
    }

    private fun fitRect(
        imageWidth: Float,
        imageHeight: Float,
        pageWidth: Float,
        pageHeight: Float
    ): RectF {
        val pageRatio = pageWidth / pageHeight
        val imageRatio = imageWidth / imageHeight
        var drawWidth = pageWidth
        var drawHeight = pageHeight
        var left = 0f
        var top = 0f

        if (imageRatio > pageRatio) {
            drawWidth = pageWidth
            drawHeight = pageWidth / imageRatio
            top = (pageHeight - drawHeight) * 0.5f
        } else {
            drawHeight = pageHeight
            drawWidth = pageHeight * imageRatio
            left = (pageWidth - drawWidth) * 0.5f
        }
        return RectF(left, top, left + drawWidth, top + drawHeight)
    }
}
