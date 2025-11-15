// File: lib/core/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart'; // Add this if you want to make it a Riverpod provider

// Define a provider for LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider); // Get the shared SharedPreferences instance
  return LocalStorageService(prefs);
});


class LocalStorageService {
  final SharedPreferences _prefs;

  // Constructor now requires a SharedPreferences instance
  LocalStorageService(this._prefs);

  // Remove the static init() method. Initialization happens in main().

  static const String _onboardingCompleteKey = 'onboarding_complete';

  Future<bool> getOnboardingComplete() async {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingCompleteKey, complete);
  }

// Add methods to get/set other preferences if needed
// Example:
// Future<String?> getUserId() async {
//   return _prefs.getString('user_id');
// }
// Future<void> setUserId(String id) async {
//   await _prefs.setString('user_id', id);
// }
}