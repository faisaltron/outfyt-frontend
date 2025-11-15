// lib/core/utils/face_shape_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaceShapeSelector extends StatelessWidget {
  final String detectedFaceShape;

  // Make sure this list contains all shapes your _classifyFaceShape can return
  // and for which you have corresponding SVG assets.
  static List<String> faceShapes = [
    "oval",
    "round",
    "triangle",
    "oblong",
    "diamond",
    "rectangle",
  ];

  const FaceShapeSelector({super.key, required this.detectedFaceShape});

  @override
  Widget build(BuildContext context) {
    return Column( // Changed from Positioned to Column as it's now wrapped by Positioned in MyLooksScreen
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: faceShapes.map((shape) {
        bool isSelected = shape.toLowerCase() == detectedFaceShape.toLowerCase();
        return Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            border: isSelected ? Border.all(color: Colors.red, width: 2) : null, // Reverted border color to red as per original
          ),
          child: SvgPicture.asset(
            'assets/faceshapes/$shape.svg',
            // No colorFilter in original, so let's remove it if you want strict match
            // colorFilter: isSelected ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
            // placeholderBuilder: (BuildContext context) => const Icon(Icons.image_not_supported, size: 20),
          ),
        );
      }).toList(),
    );
  }
}