import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Size previewSize; // The raw preview size from cameraController.value.previewSize
  final Size screenSize;   // The actual size of the widget on screen
  final bool isFrontCamera;

  FacePainter({
    required this.faces,
    required this.previewSize,
    required this.screenSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    final Paint contourPaint = Paint()
      ..color = Colors.white // White for the main face contour
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..filterQuality = FilterQuality.high;

    // Determine the effective preview size in the orientation it's displayed on screen.
    // The camera feed typically gives width/height as if it were in landscape.
    // For a portrait app preview, these dimensions are effectively swapped.
    final double imageWidth = previewSize.height; // Actual width of the image seen in portrait orientation
    final double imageHeight = previewSize.width; // Actual height of the image seen in portrait orientation

    // Calculate scaling factors to map camera image pixels to screen pixels
    final double scaleX = screenSize.width / imageWidth;
    final double scaleY = screenSize.height / imageHeight;

    for (final face in faces) {
      // --- REMOVED DEBUGGING STEP: Drawing the Bounding Box ---
      // This code was removed to clean up the UI as requested.
      // If you need to re-diagnose alignment issues, you can temporarily
      // add it back using the code from previous responses.


      // --- Draw the Face Contour ---
      final contour = face.contours[FaceContourType.face];
      if (contour == null || contour.points.isEmpty) continue;

      final Path path = Path();

      for (int i = 0; i < contour.points.length; i++) {
        double x = contour.points[i].x.toDouble();
        double y = contour.points[i].y.toDouble();

        // Apply mirroring for front camera *before* scaling
        if (isFrontCamera) {
          x = imageWidth - x; // Mirror x-coordinate horizontally relative to the camera image's width
        }

        // Apply scaling
        x *= scaleX;
        y *= scaleY;

        // --- OPTIONAL: Apply small, consistent offsets for visual alignment ---
        // Uncomment and adjust these values if, after all other optimizations,
        // the contour is still slightly and consistently off.
        // const double offsetX = 0.0; // Positive moves right, negative moves left
        // const double offsetY = 0.0; // Positive moves down, negative moves up
        // x += offsetX;
        // y += offsetY;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, contourPaint);
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return faces != oldDelegate.faces ||
        previewSize != oldDelegate.previewSize ||
        screenSize != oldDelegate.screenSize ||
        isFrontCamera != oldDelegate.isFrontCamera;
  }
}