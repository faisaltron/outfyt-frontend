import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart'; // Assuming apiClientProvider is here

class PurchaseRecommendationScreen extends ConsumerStatefulWidget {
  const PurchaseRecommendationScreen({super.key});

  @override
  ConsumerState<PurchaseRecommendationScreen> createState() => _PurchaseRecommendationScreenState();
}

class _PurchaseRecommendationScreenState extends ConsumerState<PurchaseRecommendationScreen> {
  File? _imageFile;
  String? _recommendationMessage;
  int? _recommendationRating;
  // Removed: String? _category; // No longer returned by backend
  // Removed: String? _color;    // No longer returned by backend
  // Removed: List<dynamic>? _styles; // No longer returned by backend
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        // Clear previous recommendation data when a new image is picked
        _recommendationMessage = null;
        _recommendationRating = null;
        // Removed: _category = null;
        // Removed: _color = null;
        // Removed: _styles = null;
        _isLoading = false; // Reset loading state
      });
    }
  }

  Future<void> _getRecommendation() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendationMessage = null;
      _recommendationRating = null;
      // Removed: _category = null;
      // Removed: _color = null;
      // Removed: _styles = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final result = await apiClient.getPurchaseRecommendation(_imageFile!);

      setState(() {
        _recommendationRating = result['rating'];
        _recommendationMessage = result['message'];
        // Removed: _category = result['category'];
        // Removed: _color = result['color'];
        // Removed: _styles = result['styles'];
      });
    } catch (e) {
      setState(() {
        _recommendationMessage = 'Error getting recommendation: ${e.toString()}'; // Use toString() for error message
        _recommendationRating = null;
        // Removed: _category = null;
        // Removed: _color = null;
        // Removed: _styles = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRatingStars(int? rating) {
    if (rating == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.pink, // Changed color to pink as requested
          size: 28, // Slightly larger stars
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Recommendation'),
        backgroundColor: Colors.white, // Match HomeScreen AppBar
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded( // Allows the content to take available space
            child: SingleChildScrollView( // For scrollability if content overflows
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch image container
                children: [
                  // Image Display Container
                  Container(
                    height: 250, // Increased height for better display
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: Center(
                      child: _imageFile != null
                          ? ClipRRect( // Clip to match container border radius
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                          : const Text(
                        'Upload an image to get a recommendation',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Increased spacing

                  // Recommendation Details
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: Colors.pink)) // Pink loading indicator
                  else if (_recommendationMessage != null)
                    Column(
                      children: [
                        _buildRatingStars(_recommendationRating), // Pink stars
                        const SizedBox(height: 10),
                        Text(
                          _recommendationMessage!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Removed: if (_category != null)
                        // Removed:   Text(
                        // Removed:     'Category: $_category',
                        // Removed:     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        // Removed:   ),
                        // Removed: if (_color != null)
                        // Removed:   Text(
                        // Removed:     'Color: $_color',
                        // Removed:     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        // Removed:   ),
                        // Removed: if (_styles != null && _styles!.isNotEmpty)
                        // Removed:   Text(
                        // Removed:     'Styles: ${_styles!.join(', ')}',
                        // Removed:     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        // Removed:     textAlign: TextAlign.center,
                        // Removed:   ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Bottom Buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3), // subtle shadow on top
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Keep buttons compact
              children: [
                SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Pink button
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Spacing between buttons
                SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo with Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink, // Pink button
                      foregroundColor: Colors.white, // White text
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12), // Spacing between buttons
                SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getRecommendation, // Disable button if loading
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Get Purchase Recommendation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade700, // Slightly darker pink for emphasis
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14), // Slightly taller button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      disabledBackgroundColor: Colors.pink.shade200, // Gray out when disabled
                      disabledForegroundColor: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // Set Scaffold background to white
    );
  }
}