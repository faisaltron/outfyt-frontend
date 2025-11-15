// File: lib/features/profile/about_you_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../auth/data/services/auth_service.dart';

final aboutYouControllerProvider = StateNotifierProvider.autoDispose<AboutYouController, AboutYouState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider.notifier);
  return AboutYouController(apiClient: apiClient, authService: authService);
});

// State class for AboutYouScreen
class AboutYouState {
  final String? selectedGender;
  final Set<String> selectedStyle;
  final bool showStyleSelection;
  final bool isSaving;

  AboutYouState({
    this.selectedGender,
    Set<String>? selectedStyle,
    this.showStyleSelection = false,
    this.isSaving = false,
  }) : selectedStyle = selectedStyle ?? {};

  AboutYouState copyWith({
    String? selectedGender,
    Set<String>? selectedStyle,
    bool? showStyleSelection,
    bool? isSaving,
  }) {
    return AboutYouState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedStyle: selectedStyle ?? this.selectedStyle,
      showStyleSelection: showStyleSelection ?? this.showStyleSelection,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AboutYouController extends StateNotifier<AboutYouState> {
  final ApiClient _apiClient;
  final AuthService _authService;

  AboutYouController({required ApiClient apiClient, required AuthService authService})
      : _apiClient = apiClient,
        _authService = authService,
        super(AboutYouState());

  void selectGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  void selectStyle(String style) {
    final updatedStyles = Set<String>.from(state.selectedStyle);
    if (updatedStyles.contains(style)) {
      updatedStyles.remove(style);
    } else {
      updatedStyles.add(style);
    }
    state = state.copyWith(selectedStyle: updatedStyles);
  }

  void toggleStyleSelectionVisibility() {
    state = state.copyWith(showStyleSelection: !state.showStyleSelection);
  }

  Future<void> onSave(BuildContext context) async {
    // Check if on first step
    if (!state.showStyleSelection) {
      // If gender is not selected yet, prompt for it
      if (state.selectedGender == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your gender before proceeding.')),
          );
        }
        return;
      }
      state = state.copyWith(showStyleSelection: true); // Move to second step
      return;
    }

    // Validation for second step (after gender is selected and user can select styles)
    if (state.selectedStyle.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one style preference.')),
        );
      }
      return;
    }

    state = state.copyWith(isSaving: true);
    try {
      // 1. Update Profile (Gender)
      // Your backend expects 'M' or 'F', so map 'Male'/'Female' accordingly
      final genderToSend = state.selectedGender == 'Male' ? 'Male' : 'Female';
      await _apiClient.put(
        '/auth/profile/',
        {'gender': genderToSend},
      );

      // 2. Save Style Preferences (Send each style separately)
      // This is the crucial part that ensures the backend receives the expected format.
      for (String style in state.selectedStyle) {
        await _apiClient.post(
          '/auth/style-preferences/',
          {'style': style}, // Send each style as {'style': 'StyleName'}
        );
      }

      // Check if profile is now completed (your AuthService handles this implicitly)
      // This will make an API call to '/profile/' again, which is fine to confirm completion.
      final bool isProfileComplete = await _authService.isProfileCompleted();

      debugPrint('Profile saved successfully.');
      if (context.mounted) {
        if (isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, '/personalizationsplash', (route) => false);
        } else {
          // This case should ideally not happen if both gender and style are correctly set.
          // You might want to handle it (e.g., show a more specific error or log).
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved, but still incomplete. Please try again or contact support.'),
            ),
          );
        }
      }
    } catch (e, st) {
      debugPrint('Failed to save profile: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: ${e.toString()}')),
        );
      }
    } finally {
      if (context.mounted) {
        state = state.copyWith(isSaving: false);
      }
    }
  }
}