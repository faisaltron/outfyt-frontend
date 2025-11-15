import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import '../../../../core/network/api_client.dart'; // <--- UPDATED IMPORT PATH (was api_service.dart)
import '../../../../core/config/api_config.dart';
import '../../../../core/providers.dart';

// Define a Riverpod provider for OutfitService
final outfitServiceProvider = Provider<OutfitService>((ref) {
  // Get the ApiClient instance from its Riverpod provider
  final apiClient = ref.watch(apiClientProvider);
  return OutfitService(apiClient: apiClient);
});


class OutfitService {
  final ApiClient _apiClient;

  // Constructor now requires ApiClient to be injected
  OutfitService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Get outfit recommendations
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      // Use the injected _apiClient
      final response = await _apiClient.get(ApiConfig.getRecommendations);
      final List<dynamic> outfitsJson = response['outfits'];
      return outfitsJson.cast<Map<String, dynamic>>();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle errors
  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(500, error.toString());
  }
}



  /// Save an outfit
  // Future<Map<String, dynamic>> saveOutfit(
  //   List<String> itemIds,
  //   String? name,
  //   String? description,
  // ) async {
  //   try {
  //     final response = await _apiService.post(
  //       ApiConfig.saveOutfit,
  //       {
  //         'items': itemIds,
  //         if (name != null) 'name': name,
  //         if (description != null) 'description': description,
  //       },
  //     );
  //     return response;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  /// Get saved outfits
  // Future<List<Map<String, dynamic>>> getSavedOutfits() async {
  //   try {
  //     final response = await _apiService.get(ApiConfig.getSavedOutfits);
  //     final List<dynamic> outfitsJson = response['outfits'];
  //     return outfitsJson.cast<Map<String, dynamic>>();
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  /// Delete a saved outfit
  // Future<void> deleteOutfit(String outfitId) async {
  //   try {
  //     await _apiService.delete('${ApiConfig.getSavedOutfits}$outfitId');
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

  /// Update outfit details
  // Future<Map<String, dynamic>> updateOutfit(
  //   String outfitId,
  //   String? name,
  //   String? description,
  // ) async {
  //   try {
  //     final response = await _apiService.put(
  //       '${ApiConfig.getSavedOutfits}$outfitId',
  //       {
  //         if (name != null) 'name': name,
  //         if (description != null) 'description': description,
  //       },
  //     );
  //     return response;
  //   } catch (e) {
  //     throw _handleError(e);
  //   }
  // }

