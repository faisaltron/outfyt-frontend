import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart'; // <--- Import your ApiClient
import '../../../../core/providers.dart';
import '../../../auth/data/services/auth_service.dart';

final aboutYouControllerProvider = StateNotifierProvider.autoDispose<AboutYouController, AboutYouState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authService = ref.watch(authServiceProvider.notifier); // Or simply read if you don't need to react to changes
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
  final AuthService _authService; // To mark profile as complete if backend doesn't handle it implicitly

  AboutYouController({required ApiClient apiClient, required AuthService authService})
      : _apiClient = apiClient,
        _authService = authService,
        super(AboutYouState()); // Initial state

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
      state = state.copyWith(showStyleSelection: true);
      return;
    }

    // Validation for second step
    if (state.selectedGender == null || state.selectedStyle.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select gender and at least one style.')),
        );
      }
      return;
    }

    state = state.copyWith(isSaving: true);
    try {
      // Update profile
      await _apiClient.put('/auth/profile/', {
        'gender': state.selectedGender,
      });

      // Save style preferences (assuming endpoint exists)
      // This is often a single call with a list of styles, not multiple calls.
      // Adjust according to your backend's actual endpoint.
      await _apiClient.post('/auth/style-preferences/', {'styles': state.selectedStyle.toList()}); // Example for sending list

      // Mark profile as complete through AuthService if needed (backend-driven usually means this is implicit)
      // await _authService.markProfileCompleted(); // Example if AuthService has such a method

      debugPrint('Profile saved successfully, navigating to PersonalizationSplashScreen');
      if (context.mounted) {
        // Since profile completion is backend-driven, AuthState might not need direct update here.
        // The next screen's logic (PersonalizationSplashScreen or /holder) will re-check.
        Navigator.pushNamedAndRemoveUntil(context, '/personalizationsplash', (route) => false);
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