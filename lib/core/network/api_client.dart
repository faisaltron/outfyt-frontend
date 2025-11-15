import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart'; // For debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart'; // Your API config
import 'package:http_parser/http_parser.dart'; // Required for MediaType

class ApiClient {
  static const String baseUrl = ApiConfig.baseUrl; // Use ApiConfig's baseUrl
  final http.Client _client = http.Client();
  final SharedPreferences _prefs;

  // No need for a public getter for prefs; ApiClient manages them internally.
  ApiClient(this._prefs);

  // --- Methods for Auth Service to use for token management ---
  Future<void> setAuthTokens(String accessToken, {String? refreshToken}) async {
    debugPrint('[ApiClient] Setting access_token in SharedPreferences');
    await _prefs.setString('access', accessToken);
    if (refreshToken != null) {
      debugPrint('[ApiClient] Setting refresh_token in SharedPreferences');
      await _prefs.setString('refresh', refreshToken);
    }
  }

  Future<void> clearAuthTokens() async {
    debugPrint('[ApiClient] Clearing tokens from SharedPreferences');
    await _prefs.remove('access');
    await _prefs.remove('refresh');
  }

  String? getAccessToken() {
    return _prefs.getString('access');
  }

  String? getRefreshToken() {
    return _prefs.getString('refresh');
  }
  // --- END Token Management Methods ---

  // --- Integrated Token Refresh Logic from old ApiService ---
  // This logic is now handled by the AuthService directly, which will use ApiClient
  // to make the refresh call and then use ApiClient.setAuthTokens to store the new tokens.
  // ApiClient itself just makes the raw requests.

  // Helper to get headers with the latest token
  Map<String, String> _getHeaders({String? tokenOverride}) {
    final token = tokenOverride ?? getAccessToken(); // Use provided token or current access token
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Common request logic to add retries (from old ApiService)
  Future<T> _performRequestWithRetries<T>(Future<T> Function() operation) async {
    int retryCount = 0;
    const int maxRetries = 3; // Define maxRetries here or in ApiConfig

    while (retryCount < maxRetries) {
      try {
        return await operation();
      } on ApiException catch (e) {
        if (e.statusCode == 401 && retryCount < maxRetries -1) { // Only retry if 401 and not on last attempt
          debugPrint('[ApiClient] Token expired/invalid. Attempting refresh and retry...');
          // The AuthService (caller) is responsible for handling token refresh.
          // ApiClient should not try to refresh itself without knowing the AuthService logic.
          // For now, we just re-throw, and AuthService catches it.
          // If you *really* want auto-refresh here, it gets complex.
          // For a clean separation, AuthService calls ApiClient to perform requests,
          // and if ApiClient throws 401, AuthService handles the refresh and retries the original call.
          rethrow; // Let the calling service handle the 401 and retry
        }
        rethrow; // Re-throw other API exceptions
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          throw _handleError(e); // Re-throw if max retries reached
        }
        debugPrint('[ApiClient] Request failed. Retrying... (Attempt $retryCount/$maxRetries)');
        await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
      }
    }
    throw ApiException(500, 'Max retry attempts reached'); // Should not be reached
  }

  Future<dynamic> get(String endpoint) async {
    return _performRequestWithRetries(() async {
      debugPrint('[ApiClient] GET $baseUrl$endpoint');
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    return _performRequestWithRetries(() async {
      debugPrint('[ApiClient] POST $baseUrl$endpoint');
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    return _performRequestWithRetries(() async {
      debugPrint('[ApiClient] PUT $baseUrl$endpoint');
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> delete(String endpoint) async {
    return _performRequestWithRetries(() async {
      debugPrint('[ApiClient] DELETE $baseUrl$endpoint');
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );
      return _handleResponse(response); // Handle 204 or no content
    });
  }

  Future<dynamic> uploadFile(String endpoint, String filePath, String fieldName) async {
    return _performRequestWithRetries(() async {
      debugPrint('[ApiClient] UPLOAD $baseUrl$endpoint');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(_getHeaders()); // Multipart headers don't need Content-Type explicitly
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      var streamedResponse = await request.send();
      var responseData = await streamedResponse.stream.bytesToString();
      return _handleResponse(http.Response(responseData, streamedResponse.statusCode));
    });
  }

  // Existing _handleResponse and ApiException are good.
  dynamic _handleResponse(http.Response response) {
    debugPrint('[ApiClient] _handleResponse - URL: ${response.request?.url}');
    debugPrint('[ApiClient] _handleResponse - Status: ${response.statusCode}');
    debugPrint('[ApiClient] _handleResponse - Raw Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        debugPrint('[ApiClient] _handleResponse: Status ${response.statusCode}, Body is empty or 204. Returning null.');
        return null;
      }
      try {
        final decoded = json.decode(response.body);
        debugPrint('[ApiClient] _handleResponse: Successfully decoded JSON. Type: ${decoded.runtimeType}');
        return decoded;
      } catch (e) {
        debugPrint('[ApiClient] _handleResponse: JSON Decoding Error for URL ${response.request?.url}, Status ${response.statusCode}. Error: $e');
        debugPrint('Raw response body that caused JSON error: ${response.body}');
        throw ApiException(
          response.statusCode,
          'Failed to decode JSON. Server sent malformed or unexpected data for URL: ${response.request?.url}. Error: $e.',
        );
      }
    } else {
      String errorMessage = 'Server error with status ${response.statusCode} for URL: ${response.request?.url}.';
      try {
        if (response.body.isNotEmpty) {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorBody['message'] as String? ?? errorBody['error']?['message'] ?? errorMessage;
        } else {
          errorMessage += ' No response body provided.';
        }
      } catch (_) {
        errorMessage += ' Raw body: ${response.body}.';
      }
      debugPrint('[ApiClient] _handleResponse: API Error. $errorMessage');
      throw ApiException(response.statusCode, errorMessage);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error is http.ClientException) {
      return ApiException(0, 'Network error: ${error.message}');
    }
    if (error is FormatException) {
      return ApiException(500, 'Invalid response format');
    }
    return ApiException(500, error.toString());
  }
  Future<Map<String, dynamic>> getPurchaseRecommendation(File imageFile) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/wardrobe/recommend_purchase/');
    final request = http.MultipartRequest('POST', url);

    // Get token using your existing getAccessToken() from SharedPreferences
    String? accessToken = getAccessToken(); // <--- FIXED: No await, as getAccessToken() is sync
    if (accessToken == null) {
      throw ApiException(401, 'No access token available.');
    }
    request.headers['Authorization'] = 'Bearer $accessToken';

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'), // <--- FIXED: Proper MediaType import/usage
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get purchase recommendation: $e');
    }
  }

}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}