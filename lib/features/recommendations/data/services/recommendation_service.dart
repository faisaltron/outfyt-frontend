import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../data/models/outfit.dart'; // Ensure correct path
import '../../data/repositories/recommendations_repository.dart';

// Provider for RecommendationService
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final repository = RecommendationsRepository(apiClient);
  return RecommendationService(repository);
});


class RecommendationService {
  final RecommendationsRepository _repository;

  RecommendationService(this._repository);

  /// Fetches outfit recommendations and maps them to Outfit models.
  Future<List<Outfit>> getRecommendations() async {
    try {
      final List<Map<String, dynamic>> data = await _repository.getOutfitSuggestions();
      return data.map((json) => Outfit.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommendations: $e');
    }
  }

  /// Fetches saved outfits and maps them to Outfit models.
  /// Assumes `RecommendationsRepository` has a `getSavedOutfitSuggestions` method.
  // Future<List<Outfit>> getSavedOutfits() async {
  //   try {
  //     final List<Map<String, dynamic>> data = await _repository.getSavedOutfitSuggestions();
  //     return data.map((json) => Outfit.fromJson(json)).toList();
  //   } catch (e) {
  //     throw Exception('Failed to fetch saved outfits: $e');
  //   }
  // }

  /// Saves an outfit by sending its ID to the backend.
  /// Returns the saved Outfit (potentially with `isSaved` updated).
  // Future<Outfit> saveOutfit(Outfit outfit) async {
  //   try {
  //     await _repository.saveOutfitSuggestion(int.parse(outfit.id));
  //     // Return a copy of the outfit with isSaved set to true, or re-fetch saved outfits
  //     return outfit.copyWith(isSaved: true);
  //   } catch (e) {
  //     throw Exception('Failed to save outfit: $e');
  //   }
  // }

  /// Deletes/unsaves an outfit by sending its ID to the backend.
  // Future<void> deleteOutfit(String outfitId) async {
  //   try {
  //     // Assuming `dismissOutfitSuggestion` can be used to unsave an outfit.
  //     await _repository.dismissOutfitSuggestion(int.parse(outfitId));
  //   } catch (e) {
  //     throw Exception('Failed to delete outfit: $e');
  //   }
  // }

  /// Updates an outfit. This method is typically used for modifying properties
  /// of a *saved* outfit. Requires a corresponding backend endpoint and repository method.
  /// Currently throws `UnimplementedError` as it's not directly supported by the provided repository methods.
  Future<Outfit> updateOutfit(String outfitId, Outfit outfit) async {
    // Implement this if your backend supports updating an outfit's details.
    // Example: final updatedData = await _repository.updateOutfit(outfitId, outfit.toJson());
    // return Outfit.fromJson(updatedData);
    throw UnimplementedError('Update outfit not directly supported via repository for recommendations.');
  }
}