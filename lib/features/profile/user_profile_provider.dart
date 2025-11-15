import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_fashion_app/core/network/api_client.dart'; // Adjust path
import 'package:new_fashion_app/features/auth/data/services/auth_service.dart'; // For authServiceProvider

// Define the state for our user profile
class UserProfileState {
  final Map<String, dynamic>? userData;
  final bool isLoading;
  final String? error;

  UserProfileState({this.userData, this.isLoading = false, this.error});

  UserProfileState copyWith({
    Map<String, dynamic>? userData,
    bool? isLoading,
    String? error,
  }) {
    return UserProfileState(
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// StateNotifier for fetching and managing user profile data
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final ApiClient _apiClient;
  final AuthService _authService; // To ensure token validity

  UserProfileNotifier(this._apiClient, this._authService) : super(UserProfileState(isLoading: true)) {
    // Initial fetch when the provider is created
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true, error: null); // Set loading state

    try {
      await _authService.ensureValidToken(); // Ensure token is valid before API call
      final response = await _apiClient.get('/auth/profile/'); // Fetch from your Django backend
      state = state.copyWith(userData: response, isLoading: false); // Set data and turn off loading
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false); // Set error and turn off loading
      // You can add more specific error handling here if needed
      debugPrint('Error fetching user profile in UserProfileNotifier: $e');
    }
  }

// Optional: Method to update a specific field in the profile if needed from UI
// Future<void> updateUsername(String newUsername) async {
//   if (state.userData == null) return;
//   try {
//     await _authService.ensureValidToken();
//     final response = await _apiClient.patch('/profile/', {'username': newUsername});
//     state = state.copyWith(userData: response); // Update local state with new data
//   } catch (e) {
//     // Handle update error
//   }
// }
}
