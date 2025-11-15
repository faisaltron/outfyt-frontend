import 'package:new_fashion_app/core/config/api_config.dart';
import 'package:flutter/foundation.dart';

/// Model class representing a wardrobe item
class WardrobeItem {
  final String id;
  final String imageUrl;
  final String category; // Name of the category
  final String color;    // Name of the color
  final List<String> styles; // Names of the styles
  final String? gender; // Made nullable as it's not always in GET response
  final DateTime createdAt; // Renamed to createdAt to match backend's GET
  final String? backendId;

  // Constructor
  WardrobeItem({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.color,
    required this.styles,
    this.gender, // No longer required due to nullable type
    required this.createdAt, // Renamed
    this.backendId,
  });

  /// Convert to JSON for API requests (primarily for POST/PUT)
  // This method now assumes backend expects simpler fields for creation/update
  Map<String, dynamic> toJson() {
    return {
      // 'id': backendId ?? id, // 'id' typically not sent on create
      'image': imageUrl, // Backend expects 'image' not 'image_url' for image uploads
      'category': category, // For creating, usually expects name or ID, let's assume name for now
      'color': color,       // For creating, usually expects name or ID
      'styles': styles,     // For creating, usually expects list of names or IDs
      if (gender != null) 'gender': gender, // Only send if not null, or if explicitly required by backend
      'upload_date': createdAt.toIso8601String(), // Using createdAt for consistency
    };
  }

  /// Create from JSON response (for GET)
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    // Helper to get string name from nested object or direct string
    String extractName(dynamic obj) {
      if (obj == null) return 'Unknown';
      if (obj is String) return obj;
      if (obj is Map && obj.containsKey('name')) return obj['name'];
      return obj.toString();
    }

    // Helper to build full image URL from relative path or direct URL
    String buildImageUrl(dynamic image) {
      if (image == null) return '';
      final url = image.toString();
      if (url.startsWith('http')) return url;
      final base = ApiConfig.baseUrl.endsWith('/api')
          ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 4)
          : ApiConfig.baseUrl;
      return '$base$url';
    }

    debugPrint('[WardrobeItem.fromJson] Parsing item: $json');

    return WardrobeItem(
      id: json['id']?.toString() ?? '',
      backendId: json['id']?.toString(),
      imageUrl: buildImageUrl(json['image']),
      category: extractName(json['category']),
      color: extractName(json['color']),
      styles: (json['styles'] as List?)?.map((s) => extractName(s)).toList() ?? [],
      gender: json.containsKey('gender') ? json['gender']?.toString() : 'unisex',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  WardrobeItem copyWith({
    String? id,
    String? imageUrl,
    String? category,
    String? color,
    List<String>? styles,
    String? gender,
    DateTime? createdAt, // Changed from uploadDate
    String? backendId,
  }) {
    return WardrobeItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      color: color ?? this.color,
      styles: styles ?? this.styles,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt, // Changed from uploadDate
      backendId: backendId ?? this.backendId,
    );
  }
}