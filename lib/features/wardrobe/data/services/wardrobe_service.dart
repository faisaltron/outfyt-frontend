import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart'; // Ensure this path is correct
import '../../../../core/providers.dart';
import '../models/wardrobe_item.dart';
import 'package:flutter/foundation.dart';

// Your existing ApiException class (no changes here)
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: $statusCode, $message';
}

// Define a Riverpod provider for WardrobeService
final wardrobeServiceProvider = Provider<WardrobeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WardrobeService(apiClient: apiClient);
});

/// Service class for handling wardrobe-related API operations.
/// It encapsulates all HTTP requests to the backend for the wardrobe feature.
class WardrobeService {
  final ApiClient _apiClient;

  // Constructor now requires ApiClient to be injected
  WardrobeService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Fetches all wardrobe items from the backend.
  Future<List<WardrobeItem>> getItems() async {
    try {
      final response = await _apiClient.get(ApiConfig.wardrobeItems);
      debugPrint('[WardrobeService] getItems raw response:');
      debugPrint(response.toString());
      final List<dynamic> itemsJson = response['items'] as List<dynamic>? ?? [];
      return itemsJson.map((json) => WardrobeItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw _handleError(e, "Failed to fetch wardrobe items");
    }
  }
  // NEW: Method to delete a wardrobe item
  Future<void> deleteItem(String itemId) async {
    try {
      await _apiClient.delete('/wardrobe/items/$itemId/');
      debugPrint('Item $itemId deleted successfully from backend.');
    } catch (e) {
      debugPrint('Error in WardrobeService.deleteItem: $e');
      rethrow; // Re-throw the exception for the controller to handle
    }
  }

  /// Uploads a new wardrobe item (image and gender) to the backend.
  Future<WardrobeItem> uploadItem(File image, String gender) async {
    try {
      // CORRECTED: Access baseUrl as a static member on ApiClient
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}${ApiConfig.uploadImage}'), // <--- FIX: Use ApiClient.baseUrl
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Field name expected by the backend for the image
          image.path,
        ),
      );

      request.fields['gender'] = gender;

      // CORRECTED: Access authToken from _apiClient instance's getter (assuming it's public)
      // If authToken is private (e.g., _authToken), you'll need a public getter in ApiClient,
      // or the _apiClient needs a method to provide headers.
      // Assuming ApiClient has a public getter for the token like `token` or `getAuthToken()`.
      // If `_apiClient.authToken` truly doesn't exist, we need to adjust ApiClient itself
      // or how its token is provided. For now, let's assume it should be exposed.
      // If your ApiClient wraps a token *provider*, you might do:
      // final token = await _apiClient.tokenProvider.getToken();
      // request.headers['Authorization'] = 'Bearer $token';

      // Let's assume ApiClient has a public getter for `authToken` or a method to get headers.
      // If it doesn't, this is the part where we'd need to modify ApiClient or how it provides the token.
      // For now, I'll assume a public `token` getter or a method to get the header string.
      // If ApiClient itself stores the token, it needs to expose it.
      // Given the previous pattern, ApiClient should indeed expose its token or an `Authorization` header directly.
      // If your ApiClient's internal token is indeed '_authToken', then you need a public getter in ApiClient:
      // String? get authToken => _authToken;
      // Or simply:
      // Map<String, String> getAuthHeaders() { return {'Authorization': 'Bearer $_authToken'}; }

      // Let's use a robust way. Assuming ApiClient has a method like `getAuthorizationHeader()`
      // or `getToken()` or if it directly exposes `authToken` publicly.
      // If `ApiClient`'s token is private, you need to add a public getter to `ApiClient`:
      // Example in `ApiClient`:
      // class ApiClient {
      //   String? _authToken; // private
      //   String? get currentToken => _authToken; // public getter
      // }
      // Then you'd use: request.headers['Authorization'] = 'Bearer ${_apiClient.currentToken}';

      // **MOST LIKELY SCENARIO:** Your `ApiClient` should have a public getter for the token
      // or a method that returns the complete header. Let's assume a public `token` getter for simplicity.
      // If it's private, you need to expose it in `ApiClient`.
      // For now, let's assume `_apiClient` has a public getter named `getToken` or `getAuthToken` that returns the token string.
      // If not, it means the `ApiClient` itself handles adding headers to requests.
      // However, for MultipartRequest, you often need to add them manually.

      // If `ApiClient` has a public `token` getter:
      final token = _apiClient.getAccessToken(); // Assuming this method exists and provides the token
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // If `ApiClient` also has a method to get standard headers:
      // request.headers.addAll(_apiClient.getHeaders()); // assuming it returns Map<String, String>

      request.headers['Content-Type'] = 'multipart/form-data'; // Explicitly set content type

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) { // HTTP 201 Created: Success
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return WardrobeItem.fromJson(responseData);
      } else {
        String errorMessage = 'Upload failed';
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorBody['message'] as String? ?? errorMessage;
        } catch (_) {
          if(response.body.isNotEmpty) errorMessage = response.body;
        }
        throw ApiException(response.statusCode, errorMessage);
      }
    } catch (e) {
      throw _handleError(e, "Failed to upload item");
    }
  }


  /// Fetches available categories from the backend.
  Future<List<String>> getCategories() async {
    try {
      final dynamic response = await _apiClient.get(ApiConfig.getCategories);

      List<String> categoryNames = [];

      if (response is Map<String, dynamic> && response.containsKey('categories')) {
        final dynamic categoriesData = response['categories'];
        if (categoriesData is List) {
          for (final categoryItem in categoriesData) {
            if (categoryItem is Map<String, dynamic> && categoryItem.containsKey('name')) {
              categoryNames.add(categoryItem['name'].toString());
            } else if (categoryItem is String) {
              categoryNames.add(categoryItem);
            }
          }
        }
      } else if (response is List) {
        for (final categoryItem in response) {
          if (categoryItem is Map<String, dynamic> && categoryItem.containsKey('name')) {
            categoryNames.add(categoryItem['name'].toString());
          } else if (categoryItem is String) {
            categoryNames.add(categoryItem);
          }
        }
      }
      return categoryNames.isNotEmpty ? categoryNames.toSet().toList() : [];
    } catch (e) {
      throw _handleError(e, "Failed to fetch categories");
    }
  }

  /// Fetches user profile data from the backend.
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConfig.userProfile);
      return response;
    } catch (e) {
      throw _handleError(e, "Failed to fetch user profile");
    }
  }

  /// Centralized error handler for API calls within this service.
  Exception _handleError(dynamic error, String contextMessage) {
    if (error is ApiException) return error;
    if (error is SocketException) {
      return ApiException(0, 'No internet connection. Please check your network.');
    }
    if (error is FormatException) {
      return ApiException(0, 'Invalid response format from server.');
    }
    return ApiException(500, '$contextMessage: An unexpected error occurred.');
  }
}