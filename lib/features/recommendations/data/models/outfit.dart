import 'package:flutter/foundation.dart'; // For debugPrint

/// Model class representing an outfit
class Outfit {
  final String id;
  // We'll directly store the image URLs for the specific items
  final String? topImageUrl;
  final String? bottomImageUrl;
  final String? footwearImageUrl;

  final bool isSaved;
  // We can keep these if you still want to log/display them, otherwise they can be removed
  final String? colorScheme;
  final double? confidenceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Outfit({
    required this.id,
    this.topImageUrl,
    this.bottomImageUrl,
    this.footwearImageUrl,
    required this.isSaved,
    this.colorScheme,
    this.confidenceScore,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON response
  factory Outfit.fromJson(Map<String, dynamic> json) {
    // Helper to build full image URL from relative path or direct URL
    // (Ensure ApiConfig is correctly imported and accessible if used)
    String buildImageUrl(dynamic imagePath) {
      if (imagePath == null) return '';
      final url = imagePath.toString();
      if (url.startsWith('http')) return url;
      // Assuming ApiConfig is configured for your base URL
      // import 'package:new_fashion_app/core/config/api_config.dart';
      // final base = ApiConfig.baseUrl.endsWith('/api')
      //     ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 4)
      //     : ApiConfig.baseUrl;
      // return '$base$url';
      // For simplicity if ApiConfig isn't easily accessible here, just return the path
      return url; // Return path directly if ApiClient builds full URL
    }

    String? getImageUrlForCategory(List<dynamic> itemsJson, String categoryName) {
      try {
        final item = itemsJson.firstWhere(
              (itemData) {
            final category = itemData['category'];
            // Handles both {"category": {"name": "Top"}} and {"category": "Top"}
            final actualCategoryName = category is Map
                ? category['name']?.toString().toLowerCase()
                : category?.toString().toLowerCase();
            return actualCategoryName == categoryName.toLowerCase();
          },
          orElse: () => null, // Return null if not found
        );
        if (item != null && item is Map<String, dynamic>) {
          return buildImageUrl(item['image']); // Extract image URL
        }
      } catch (e) {
        debugPrint('Error getting image for $categoryName: $e');
      }
      return null;
    }

    final List<dynamic> itemsJson = json['items'] is List ? List<dynamic>.from(json['items']) : [];

    return Outfit(
      id: json['id']?.toString() ?? '',
      topImageUrl: getImageUrlForCategory(itemsJson, 'Top'),
      bottomImageUrl: getImageUrlForCategory(itemsJson, 'Bottom'),
      footwearImageUrl: getImageUrlForCategory(itemsJson, 'Footwear'),
      isSaved: json['is_saved'] ?? false,
      colorScheme: json['color_scheme']?.toString(),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  // No specific imageUrl for Outfit, derived from component items
  String get imageUrl => ''; // Keep this if other parts of your app expect it

  // Add copyWith for convenience
  Outfit copyWith({
    String? id,
    String? topImageUrl,
    String? bottomImageUrl,
    String? footwearImageUrl,
    bool? isSaved,
    String? colorScheme,
    double? confidenceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      topImageUrl: topImageUrl ?? this.topImageUrl,
      bottomImageUrl: bottomImageUrl ?? this.bottomImageUrl,
      footwearImageUrl: footwearImageUrl ?? this.footwearImageUrl,
      isSaved: isSaved ?? this.isSaved,
      colorScheme: colorScheme ?? this.colorScheme,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Add equality and hashCode for comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Outfit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}