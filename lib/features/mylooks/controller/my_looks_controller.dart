import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/facial_measurements.dart'; // Ensure this path is correct

/// Represents the state of the MyLooks screen.
class MyLooksState {
  final bool isCameraInitialized;
  final bool isProcessing; // Flag to prevent processing multiple images simultaneously
  final String detectedFaceShape;
  final List<Face> detectedFaces;
  final CameraController? cameraController;
  final String? error; // For displaying error messages

  MyLooksState({
    this.isCameraInitialized = false,
    this.isProcessing = false,
    this.detectedFaceShape = "Detecting...",
    this.detectedFaces = const [],
    this.cameraController,
    this.error,
  });

  /// Creates a copy of the current state with updated values.
  MyLooksState copyWith({
    bool? isCameraInitialized,
    bool? isProcessing,
    String? detectedFaceShape,
    List<Face>? detectedFaces,
    CameraController? cameraController,
    String? error,
    bool clearError = false, // Option to explicitly clear the error
  }) {
    return MyLooksState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      isProcessing: isProcessing ?? this.isProcessing,
      detectedFaceShape: detectedFaceShape ?? this.detectedFaceShape,
      detectedFaces: detectedFaces ?? this.detectedFaces,
      cameraController: cameraController ?? this.cameraController,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// MyLooksController handles the logic for camera initialization,
/// face detection, and updating the UI state via Riverpod.
class MyLooksController extends StateNotifier<MyLooksState> {
  late FaceDetector _faceDetector;

  MyLooksController() : super(MyLooksState()) {
    _initializeController();
  }

  /// Initializes the camera and sets up the face detection stream.
  Future<void> _initializeController() async {
    try {
      debugPrint("Initializing camera...");
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        debugPrint("Camera permission denied");
        state = state.copyWith(error: 'Camera permission required');
        return;
      }

      final cameras = await availableCameras();
      debugPrint("Found ${cameras.length} cameras");
      if (cameras.isEmpty) {
        debugPrint("No cameras found");
        state = state.copyWith(error: 'No cameras found');
        return;
      }

      // Prefer the front camera for face detection
      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first, // Fallback to any camera if front not found
      );
      debugPrint("Using camera: ${frontCamera.name}");

      final cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high, // Medium resolution is usually sufficient for ML Kit
        enableAudio: false, // Audio is not needed for face detection
      );

      await cameraController.initialize();
      debugPrint("Camera initialized successfully");

      // Initialize FaceDetector with desired options
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate, // Accurate mode for better results
          enableContours: true, // Required for face shape classification
          enableClassification: false,
          enableLandmarks: true,
        ),
      );

      // Update state to reflect initialized camera
      state = state.copyWith(
        cameraController: cameraController,
        isCameraInitialized: true,
        error: null, // Clear any previous errors
      );

      _startFaceDetectionStream();
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      state = state.copyWith(
        error: "Failed to initialize camera: ${e.toString()}",
        isCameraInitialized: false,
      );
    }
  }

  /// Starts the continuous image stream for face detection.
  void _startFaceDetectionStream() {
    if (!state.isCameraInitialized || state.cameraController == null) return;

    // Listen to the camera's image stream
    state.cameraController!.startImageStream((image) async {
      // Prevent processing if already processing or if the controller is no longer mounted
      // Note: `mounted` is a property of `State` objects, not `StateNotifier`.
      // For StateNotifier, you would typically check if the controller is still active/initialized.
      if (!mounted || state.isProcessing) return; // This `mounted` check is for State, and won't work directly here.

      // Set processing flag to true to prevent concurrent processing
      state = state.copyWith(isProcessing: true);

      // Process the current image frame
      await _processImage(image);

      // Set processing flag back to false after processing, if still mounted
      if (mounted) state = state.copyWith(isProcessing: false); // This `mounted` check is for State, and won't work directly here.
    });
  }

  /// Processes a single camera image to detect faces and classify their shape.
  Future<void> _processImage(CameraImage image) async {
    try {
      debugPrint("Processing image...");
      final inputImage = await _convertCameraImage(image);
      if (inputImage == null) {
        debugPrint("Failed to convert camera image");
        // Note: `mounted` is a property of `State` objects, not `StateNotifier`.
        // For StateNotifier, you would typically check if the controller is still active/initialized.
        if (mounted) state = state.copyWith(error: "Failed to convert image"); // This `mounted` check is for State, and won't work directly here.
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      debugPrint("Detected ${faces.length} faces");

      if (faces.isEmpty) {
        debugPrint("No faces detected");
        // Note: `mounted` is a property of `State` objects, not `StateNotifier`.
        // For StateNotifier, you would typically check if the controller is still active/initialized.
        if (mounted) { // This `mounted` check is for State, and won't work directly here.
          state = state.copyWith(
            detectedFaces: [],
            detectedFaceShape: "No face detected",
            error: null,
          );
        }
        return;
      }

      final face = faces.first; // Process the first detected face
      final shape = _classifyFaceShape(face).toLowerCase();
      debugPrint("Detected face shape: $shape");

      // Note: `mounted` is a property of `State` objects, not `StateNotifier`.
      // For StateNotifier, you would typically check if the controller is still active/initialized.
      if (mounted) { // This `mounted` check is for State, and won't work directly here.
        state = state.copyWith(
          detectedFaceShape: shape,
          detectedFaces: faces,
          error: null,
        );
      }
    } catch (e) {
      debugPrint("Face processing error: $e");
      // Note: `mounted` is a property of `State` objects, not `StateNotifier`.
      // For StateNotifier, you would typically check if the controller is still active/initialized.
      if (mounted) { // This `mounted` check is for State, and won't work directly here.
        state = state.copyWith(
            error: "Error processing face: ${e.toString()}"
        );
      }
    }
  }

  /// Classifies the face shape based on facial contours and measurements.
  String _classifyFaceShape(Face face) {
    final faceContour = face.contours[FaceContourType.face];
    if (faceContour == null || faceContour.points.isEmpty) return "Unknown";

    final points = faceContour.points;
    final width = face.boundingBox.width;
    final height = face.boundingBox.height;
    final faceRatio = height / width; // Height-to-width ratio

    // Calculate facial measurements
    final measurements = _getFacialMeasurements(points);

    // Classification logic (tuned to your specific needs/definitions)
    if (faceRatio < 1.1) {
      // Potentially round or square
      if (measurements.jawWidth >= width * 0.95) {
        return "Square";
      }
      if (measurements.cheekWidth > measurements.foreheadWidth * 1.2) {
        return "Diamond";
      }
      return "Round";
    }

    if (faceRatio > 1.4) {
      // Potentially oblong or heart
      if (measurements.foreheadWidth > measurements.jawWidth * 1.3) {
        return "Heart";
      }
      return "Oblong";
    }

    if (measurements.cheekWidth > measurements.foreheadWidth &&
        measurements.cheekWidth > measurements.jawWidth) {
      return "Diamond";
    }

    // Default to Oval if no other specific shape is matched
    return "Oval";
  }

  /// Extracts forehead, cheek, and jaw widths from face contour points.
  FacialMeasurements _getFacialMeasurements(List<Point> points) {
    // Find min and max Y to determine face height
    final yCoords = points.map((p) => p.y.toDouble()).toList();
    final minY = yCoords.reduce(min);
    final maxY = yCoords.reduce(max);
    final faceHeight = maxY - minY;

    // Define regions for forehead, cheek, and jaw
    final foreheadPoints = points.where((p) => p.y < minY + faceHeight * 0.25);
    final cheekPoints = points.where((p) =>
    p.y >= minY + faceHeight * 0.25 && p.y <= minY + faceHeight * 0.75);
    final jawPoints = points.where((p) => p.y > minY + faceHeight * 0.75);

    return FacialMeasurements(
      _calculateWidth(foreheadPoints),
      _calculateWidth(cheekPoints),
      _calculateWidth(jawPoints),
    );
  }

  /// Calculates the width of a given set of points.
  double _calculateWidth(Iterable<Point> points) {
    if (points.isEmpty) return 0.0;
    final xCoords = points.map((p) => p.x.toDouble()).toList();
    return (xCoords.reduce(max) - xCoords.reduce(min));
  }

  /// Converts a CameraImage to an ML Kit InputImage.
  Future<InputImage?> _convertCameraImage(CameraImage image) async {
    try {
      // Determine the correct image format based on platform
      final format = defaultTargetPlatform == TargetPlatform.android
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888; // iOS uses BGRA8888

      final inputImage = InputImage.fromBytes(
        bytes: _getImageBytes(image),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _getRotation(), // Get device/camera rotation
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
      return inputImage;
    } catch (e) {
      debugPrint("Image Conversion Error: $e");
      return null;
    }
  }

  /// Extracts image bytes from CameraImage based on platform.
  Uint8List _getImageBytes(CameraImage image) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android, convert YUV420 to NV21 format
      return _yuv420toNV21(image);
    }
    // For iOS, typically the first plane contains the BGRA bytes directly
    return image.planes[0].bytes;
  }

  /// Converts YUV420_888 CameraImage format to NV21 (YCrCb) for Android.
  Uint8List _yuv420toNV21(CameraImage image) {
    final yPlane = image.planes[0].bytes;
    // UV planes are interleaved in NV21, so we combine V and U planes
    final uvPlane = Uint8List(image.planes[1].bytes.length + image.planes[2].bytes.length);

    // Interleave U and V planes (NV21 format is Y + V + U)
    for (int i = 0; i < image.planes[2].bytes.length; i++) {
      uvPlane[2 * i] = image.planes[2].bytes[i]; // V byte
      uvPlane[2 * i + 1] = image.planes[1].bytes[i]; // U byte
    }

    return Uint8List.fromList([...yPlane, ...uvPlane]);
  }

  /// Determines the InputImageRotation based on camera sensor orientation.
  InputImageRotation _getRotation() {
    final sensorOrientation = state.cameraController?.description.sensorOrientation ?? 0;
    switch (sensorOrientation) {
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  @override
  void dispose() {
    // Crucial: Stop the image stream before disposing the camera controller
    // to prevent errors like "Bad state: Tried to use MyLooksController after `dispose` was called."
    state.cameraController?.stopImageStream();
    state.cameraController?.dispose();
    _faceDetector.close(); // Close the ML Kit face detector
    super.dispose();
  }

  /// Clears any active error message in the state.
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null, clearError: true);
    }
  }
}
