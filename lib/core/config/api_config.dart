/// API Configuration
/// This file contains all the API endpoints and configuration for the backend integration
class ApiConfig {
  /// Base URL for the Django backend
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.106:8000/api',
  );

  /// Authentication endpoints
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String logout = '/auth/logout/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String firebaseLogin = '/auth/firebase-login/';

  /// Wardrobe endpoints
  static const String wardrobeItems = '/wardrobe/items/';
  static const String uploadImage = '/wardrobe/upload/';
  static const String deleteItem = '/wardrobe/items/'; // Append item ID
  static const String updateCategory = '/wardrobe/items/'; // Append item ID
  static const String getByCategory = '/wardrobe/items/category/'; // Append category
  static const String getByStyle = '/wardrobe/items/style/'; // Append style
  static const String getByColor = '/wardrobe/items/color/'; // Append color

  /// User preferences endpoints
  static const String userPreferences = '/user/preferences/';
  static const String updatePreferences = '/user/preferences/update/';
  static const String updateStylePreferences = '/user/preferences/style/';
  static const String updateColorPreferences = '/user/preferences/color/';

  static const String userProfile = '/auth/profile';

  /// Outfit recommendation endpoints
  static const String getRecommendations = '/recommendations/outfit-suggestions/';
  static const String getSavedOutfits = '/wardrobe/outfits/';
  static const String saveOutfit = '/wardrobe/outfits/';
  static const String deleteOutfit = '/wardrobe/outfits/';
  static const String getCategories = '/wardrobe/categories/';
  static const String getStyles = '/wardrobe/styles/';
  static const String getColors = '/wardrobe/colors/';
  static const String updateOutfit = '/wardrobe/outfits/'; // Append outfit ID

  /// Headers for API requests
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Multipart headers for file upload
  static Map<String, String> getMultipartHeaders(String? token) {
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
} 