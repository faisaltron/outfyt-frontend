import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/mylooks/my_looks_screen.dart';

class HairstyleSelection extends ConsumerWidget {
  final String detectedFaceShape;

  const HairstyleSelection({
    required this.detectedFaceShape,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hairstyles = ref.watch(currentHairstylePngsProvider);

    bool showNoHairstyleMessage = false;
    String message = "";

    if (detectedFaceShape.toLowerCase() == "detecting..." ||
        detectedFaceShape.toLowerCase() == "no face detected") {
      message = ""; // No message for these states
    } else if (hairstyles.isEmpty && detectedFaceShape.toLowerCase() != "unknown") {
      message = "No hairstyles to display for '${detectedFaceShape.toUpperCase()}'";
      showNoHairstyleMessage = true;
    }

    if (showNoHairstyleMessage) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (hairstyles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center( // Center the Wrap widget
      child: Wrap( // Use Wrap for non-scrollable, multi-line layout
        alignment: WrapAlignment.center, // Center items within the wrap
        spacing: 10.0, // Horizontal spacing between items
        runSpacing: 10.0, // Vertical spacing between lines
        children: hairstyles.map((imagePath) {
          String hairstyleName = _extractHairstyleName(imagePath);

          return Container(
            padding: const EdgeInsets.all(5.39),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8.98),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hairstyleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 93.10,
                  height: 120.93,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error_outline, color: Colors.red, size: 40);
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _extractHairstyleName(String imagePath) {
    return imagePath.split('/').last.split('.').first.replaceAll('_', ' ');
  }
}