import '../../../../core/network/api_client.dart'; // Ensure correct path to ApiClient
// Import Provider


class RecommendationsRepository {
  final ApiClient _apiClient;

  RecommendationsRepository(this._apiClient);

  /// Fetches general outfit suggestions from the API.
  Future<List<Map<String, dynamic>>> getOutfitSuggestions() async {
    final dynamic data = await _apiClient.get('/recommendations/outfit-suggestions/');
    if (data is Map<String, dynamic> && data.containsKey('outfits')) {
      return List<Map<String, dynamic>>.from(data['outfits']);
    }
    return [];
  }

  /// NEW: Fetches saved outfit suggestions from the API.
  /// **IMPORTANT**: Ensure your backend has an endpoint for this, e.g., `/recommendations/saved-outfits/`.
  // Future<List<Map<String, dynamic>>> getSavedOutfitSuggestions() async {
  //   final dynamic data = await _apiClient.get('/recommendations/saved-outfits/');
  //   // Handle various API response structures
  //   if (data is List) {
  //     return List<Map<String, dynamic>>.from(data);
  //   } else if (data is Map<String, dynamic> && data.containsKey('results')) {
  //     return List<Map<String, dynamic>>.from(data['results']);
  //   }
  //   return [];
  // }

  /// Fetches purchase recommendations from the API.
  // Future<List<Map<String, dynamic>>> getPurchaseRecommendations() async {
  //   final dynamic data = await _apiClient.get('/recommendations/purchases/');
  //   if (data is List) {
  //     return List<Map<String, dynamic>>.from(data);
  //   } else if (data is Map<String, dynamic> && data.containsKey('results')) {
  //     return List<Map<String, dynamic>>.from(data['results']);
  //   }
  //   return [];
  // }

  // /// Sends a request to save an outfit suggestion by its ID.
  // Future<void> saveOutfitSuggestion(int suggestionId) async {
  //   await _apiClient.post('/recommendations/outfits/$suggestionId/save/', {});
  // }
  //
  // /// Sends a request to dismiss (or unsave) an outfit suggestion by its ID.
  // Future<void> dismissOutfitSuggestion(int suggestionId) async {
  //   await _apiClient.post('/recommendations/outfits/$suggestionId/dismiss/', {});
  // }
  //
  // /// Sends a request to save a purchase recommendation by its ID.
  // Future<void> savePurchaseRecommendation(int recommendationId) async {
  //   await _apiClient.post('/recommendations/purchases/$recommendationId/save/', {});
  // }
  //
  // /// Sends a request to dismiss a purchase recommendation by its ID.
  // Future<void> dismissPurchaseRecommendation(int recommendationId) async {
  //   await _apiClient.post('/recommendations/purchases/$recommendationId/dismiss/', {});
  // }
  //
  // /// Fetches style compatibility data from the API.
  // Future<List<Map<String, dynamic>>> getStyleCompatibility() async {
  //   final dynamic data = await _apiClient.get('/recommendations/style-compatibility/');
  //   if (data is List) {
  //     return List<Map<String, dynamic>>.from(data);
  //   } else if (data is Map<String, dynamic> && data.containsKey('results')) {
  //     return List<Map<String, dynamic>>.from(data['results']);
  //   }
  //   return [];
  // }
  //
  // /// Fetches personalized recommendations based on provided filters.
  // Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
  //   String? style,
  //   String? category,
  //   String? color,
  // }) async {
  //   final queryParams = {
  //     if (style != null) 'style': style,
  //     if (category != null) 'category': category,
  //     if (color != null) 'color': color,
  //   };
  //
  //   final dynamic data = await _apiClient.get('/recommendations/personalized/?${Uri(queryParameters: queryParams).query}');
  //   if (data is List) {
  //     return List<Map<String, dynamic>>.from(data);
  //   } else if (data is Map<String, dynamic> && data.containsKey('results')) {
  //     return List<Map<String, dynamic>>.from(data['results']);
  //   }
  //   return [];
  // }
}