import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/outfit.dart';
import 'package:new_fashion_app/features/auth/presentation/controllers/auth_state_provider.dart';
import 'package:new_fashion_app/features/recommendations/data/services/recommendation_service.dart';
import 'package:flutter/material.dart';
import 'package:new_fashion_app/features/auth/data/services/auth_service.dart';
import 'package:new_fashion_app/core/network/api_client.dart';

class RecommendationState {
  final List<Outfit> recommendations;
  final bool isLoading;
  final String? error;
  final int selectedButtonIndex; // Tracks index for temporary highlights (Share, More)
  final bool isCurrentOutfitSaved; // Persistent state for the Heart/Like icon
  final bool isCurrentOutfitBookmarked; // Persistent state for the Bookmark icon

  RecommendationState({
    required this.recommendations,
    required this.isLoading,
    this.error,
    this.selectedButtonIndex = -1,
    this.isCurrentOutfitSaved = false,
    this.isCurrentOutfitBookmarked = false, // Initialize the new bookmark state
  });

  RecommendationState copyWith({
    List<Outfit>? recommendations,
    bool? isLoading,
    String? error,
    int? selectedButtonIndex,
    bool? isCurrentOutfitSaved,
    bool? isCurrentOutfitBookmarked, // Add to copyWith
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedButtonIndex: selectedButtonIndex ?? this.selectedButtonIndex,
      isCurrentOutfitSaved: isCurrentOutfitSaved ?? this.isCurrentOutfitSaved,
      isCurrentOutfitBookmarked: isCurrentOutfitBookmarked ?? this.isCurrentOutfitBookmarked, // Copy the new field
    );
  }
}

final recommendationProvider = StateNotifierProvider<RecommendationController, RecommendationState>((ref) {
  return RecommendationController(ref);
});

class RecommendationController extends StateNotifier<RecommendationState> {
  final Ref ref;
  final RecommendationService _recommendationService;
  ProviderSubscription<AuthStatus>? _authListenerRemover;

  RecommendationController(this.ref)
      : _recommendationService = ref.read(recommendationServiceProvider),
        super(RecommendationState(
        recommendations: [],
        isLoading: false,
        error: null,
        selectedButtonIndex: -1,
        isCurrentOutfitSaved: false,
        isCurrentOutfitBookmarked: false, // Initialize here
      )) {
    _authListenerRemover = ref.listen<AuthStatus>(authServiceProvider, (previousState, newState) {
      debugPrint('[RecommendationController] AuthState changed from $previousState to $newState');
      if (newState == AuthStatus.authenticated) {
        if (state.recommendations.isEmpty || state.error != null) {
          _loadRecommendations();
        }
      } else if (newState == AuthStatus.unauthenticated) {
        state = state.copyWith(
          recommendations: [],
          isLoading: false,
          error: 'Please log in to get recommendations.',
          isCurrentOutfitSaved: false, // Reset on logout
          isCurrentOutfitBookmarked: false, // Reset on logout
          selectedButtonIndex: -1, // Reset on logout
        );
      }
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _authListenerRemover?.close();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    if (state.isLoading) {
      debugPrint('[RecommendationController] _loadRecommendations skipped: Already loading.');
      return;
    }

    debugPrint('[RecommendationController] _loadRecommendations called');
    try {
      state = state.copyWith(isLoading: true, error: null);
      final recommendations = await _recommendationService.getRecommendations();
      state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
        error: null,
        isCurrentOutfitSaved: false, // Reset saved status for new outfit
        isCurrentOutfitBookmarked: false, // Reset bookmarked status for new outfit
        selectedButtonIndex: -1, // Reset selected button for new outfit
      );
      debugPrint('[RecommendationController] Recommendations loaded successfully. Count: ${recommendations.length}');
    } on ApiException catch (e) {
      debugPrint('[RecommendationController] ApiException loading recommendations: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to fetch recommendations: ${e.message}');
    } catch (e) {
      debugPrint('[RecommendationController] Error loading recommendations: $e');
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> refreshRecommendations() async {
    if (ref.read(authServiceProvider) != AuthStatus.authenticated) {
      debugPrint('[RecommendationController] Refresh skipped: Not authenticated.');
      state = state.copyWith(error: 'Cannot refresh, not logged in.');
      return;
    }
    await _loadRecommendations();
  }

  /// Sets the index of the currently selected action button for temporary highlights.
  /// This will automatically reset after a short delay to create the "blink" effect.
  void setSelectedButton(int index) {
    debugPrint('[RecommendationController] Setting selected button index to $index');
    state = state.copyWith(selectedButtonIndex: index);

    // After a short delay, reset selectedButtonIndex for temporary highlight effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (state.selectedButtonIndex == index) { // Only reset if it's still the same button
        state = state.copyWith(selectedButtonIndex: -1);
      }
    });
  }

  /// Toggles the saved status of the current outfit (heart icon).
  /// In a real app, this would call a service to save/unsave the outfit.
  Future<void> toggleSaveStatus(Outfit outfit) async {
    // Optimistic UI update
    final newSaveStatus = !state.isCurrentOutfitSaved;
    state = state.copyWith(isCurrentOutfitSaved: newSaveStatus);
    debugPrint('[RecommendationController] Toggling save status for outfit ${outfit.id} to $newSaveStatus');

    // TODO: Integrate with backend service here
    // Example:
    // try {
    //   if (newSaveStatus) {
    //     await _recommendationService.saveOutfit(outfit.id);
    //   } else {
    //     await _recommendationService.unsaveOutfit(outfit.id);
    //   }
    //   // If backend fails, revert state (handle error)
    // } catch (e) {
    //   debugPrint('Error toggling save status: $e');
    //   state = state.copyWith(isCurrentOutfitSaved: !newSaveStatus, error: 'Failed to update save status');
    //   // Show a snackbar or message to the user about the failure
    // }
  }

  /// Toggles the bookmarked status of the current outfit (bookmark icon).
  /// This assumes a distinct "bookmark" action from "like/save".
  Future<void> toggleBookmarkStatus(Outfit outfit) async {
    final newBookmarkStatus = !state.isCurrentOutfitBookmarked;
    state = state.copyWith(isCurrentOutfitBookmarked: newBookmarkStatus);
    debugPrint('[RecommendationController] Toggling bookmark status for outfit ${outfit.id} to $newBookmarkStatus');

    // TODO: Integrate with backend service here for bookmarking/unbookmarking outfit
    // try {
    //   if (newBookmarkStatus) {
    //     await _recommendationService.bookmarkOutfit(outfit.id);
    //   } else {
    //     await _recommendationService.unbookmarkOutfit(outfit.id);
    //   }
    // } catch (e) {
    //   debugPrint('Error toggling bookmark status: $e');
    //   state = state.copyWith(isCurrentOutfitBookmarked: !newBookmarkStatus, error: 'Failed to update bookmark status');
    // }
  }
}