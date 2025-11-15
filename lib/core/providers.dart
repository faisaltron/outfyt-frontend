import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Add for debugPrint
import 'package:new_fashion_app/core/network/api_client.dart'; // Ensure ApiClient is imported
import 'package:new_fashion_app/core/services/local_storage_service.dart';
import '../features/auth/data/services/auth_service.dart';
import '../features/profile/user_profile_provider.dart';
import '../features/recommendations/data/repositories/recommendations_repository.dart';
import '../features/recommendations/data/services/recommendation_service.dart'; // Ensure LocalStorageService is imported

// Provider for SharedPreferences instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  debugPrint('--- sharedPreferencesProvider accessed - WITHOUT OVERRIDE! ---'); // ADD THIS LINE
  throw UnimplementedError('SharedPreferences must be initialized and provided in main() using ProviderScope.overrides');
});

// Provider for ApiClient, depending on the SINGLE SharedPreferences instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  debugPrint('--- apiClientProvider accessed ---'); // ADD THIS LINE
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiClient(prefs);
});

// Provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  debugPrint('--- localStorageServiceProvider accessed ---'); // ADD THIS LINE
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// Provider to asynchronously check if onboarding is complete
final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  debugPrint('--- onboardingCompletedProvider accessed ---'); // ADD THIS LINE
  final localStorageService = ref.watch(localStorageServiceProvider);
  return localStorageService.getOnboardingComplete();
});
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final apiClient = ref.watch(apiClientProvider); // This apiClientProvider must come from core/providers.dart
  final repository = RecommendationsRepository(apiClient);
  return RecommendationService(repository);
});

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider.notifier); // Access the notifier
  return UserProfileNotifier(apiClient, authService);
});

// ... (any other providers in this file, like for auth_service, etc.)
// Make sure authServiceProvider is also in this file or imported correctly.
// Assuming authServiceProvider is defined elsewhere and uses apiClientProvider or localStorageServiceProvider.