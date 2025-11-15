import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/face_painter.dart';
import '../../core/utils/face_shape_selector.dart';
import '../../core/utils/hairstyle_selection.dart';
import 'controller/my_looks_controller.dart';

// Providers remain as they are
final myLooksControllerProvider = StateNotifierProvider.autoDispose<MyLooksController, MyLooksState>((ref) {
  return MyLooksController();
});

final detectedFaceShapeProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(myLooksControllerProvider).detectedFaceShape;
});

final currentHairstylePngsProvider = Provider.autoDispose<List<String>>((ref) {
  final faceShape = ref.watch(detectedFaceShapeProvider).toLowerCase();
  final faceShapePngs = {
    "oval": ["assets/hairstyles/oval/straight.png", "assets/hairstyles/oval/wavy.png", "assets/hairstyles/oval/curly.png"],
    "round": ["assets/hairstyles/round/straight.png", "assets/hairstyles/round/wavy.png", "assets/hairstyles/round/curly.png"],
    "diamond": ["assets/hairstyles/diamond/straight.png", "assets/hairstyles/diamond/wavy.png", "assets/hairstyles/diamond/curly.png"],
    "oblong": ["assets/hairstyles/oblong/straight.png", "assets/hairstyles/oblong/wavy.png", "assets/hairstyles/oblong/curly.png"],
    "triangle": ["assets/hairstyles/triangle/straight.png", "assets/hairstyles/triangle/wavy.png", "assets/hairstyles/triangle/curly.png"],
    "square": ["assets/hairstyles/square/straight.png", "assets/hairstyles/square/wavy.png", "assets/hairstyles/square/curly.png"],
    "heart": ["assets/hairstyles/heart/straight.png", "assets/hairstyles/heart/wavy.png", "assets/hairstyles/heart/curly.png"],
    "unknown": <String>[],
    "detecting...": <String>[],
    "no face detected": <String>[],
  };
  return faceShapePngs[faceShape] ?? <String>[];
});


class MyLooksScreen extends ConsumerStatefulWidget {
  const MyLooksScreen({super.key});

  @override
  ConsumerState<MyLooksScreen> createState() => _MyLooksScreenState();
}

class _MyLooksScreenState extends ConsumerState<MyLooksScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myLooksState = ref.watch(myLooksControllerProvider);
    final detectedFaceShape = ref.watch(detectedFaceShapeProvider);
    final screenSize = MediaQuery.of(context).size;

    if (myLooksState.error != null && myLooksState.error!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(myLooksState.error!)),
          );
          ref.read(myLooksControllerProvider.notifier).clearError();
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          if (myLooksState.isCameraInitialized &&
              myLooksState.cameraController != null &&
              myLooksState.cameraController!.value.isInitialized)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: SizedBox.expand(
                child: CameraPreview(myLooksState.cameraController!),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Face Detection Overlay (uses FacePainter)
          if (myLooksState.detectedFaces.isNotEmpty &&
              myLooksState.cameraController != null &&
              myLooksState.cameraController!.value.isInitialized)
            LayoutBuilder(
              builder: (context, constraints) {
                final previewSize = myLooksState.cameraController!.value.previewSize!;
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: FacePainter(
                    faces: myLooksState.detectedFaces,
                    previewSize: previewSize,
                    screenSize: Size(constraints.maxWidth, constraints.maxHeight),
                    isFrontCamera: myLooksState.cameraController!.description.lensDirection == CameraLensDirection.front,
                  ),
                );
              },
            ),

          // Face Shape Label (New Position and Style)
          Positioned(
            top: kToolbarHeight, // Place it roughly below the status bar
            left: 0,
            right: 0,
            child: Center( // Center the child horizontally
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // More padding for button-like feel
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Transparent background
                  borderRadius: BorderRadius.circular(30), // Pill shape for button feel
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), // Subtle white border
                ),
                child: Text(
                  detectedFaceShape == "detecting..."
                      ? "DETECTING FACE..."
                      : detectedFaceShape == "no face detected"
                      ? "NO FACE DETECTED"
                      : "${detectedFaceShape.toUpperCase()} FACE",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),


          // Close Button (No change needed)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.cancel, size: 30, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Face Shape Selector (No change needed)
          Positioned(
            left: 10,
            top: screenSize.height * 0.15,
            child: FaceShapeSelector(detectedFaceShape: detectedFaceShape),
          ),

          // Hairstyle Selection (No change needed)
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: HairstyleSelection(
              detectedFaceShape: detectedFaceShape,
            ),
          ),
        ],
      ),
    );
  }
}