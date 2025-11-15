// File: lib/features/auth/presentation/controllers/signin_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Your core providers, assuming apiClientProvider is here
// The AuthService, which contains the AuthStatus enum and authServiceProvider
import '../../data/services/auth_service.dart';
// The provider that exposes the authentication status for UI
import 'auth_state_provider.dart';

/// A Riverpod [Provider] for [SigninController].
///
/// This provider creates and manages the lifecycle of [SigninController],
/// disposing of its [TextEditingController]s when no longer needed.
final signinControllerProvider = Provider<SigninController>((ref) {
  final controller = SigninController(ref);
  // Ensure that text controllers are disposed when the provider is no longer used.
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Manages the sign-in process, interacting with [AuthService]
/// and updating the application's authentication state.
class SigninController {
  final Ref ref;

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  /// Constructs a [SigninController].
  ///
  /// Requires a [Ref] to access Riverpod providers.
  SigninController(this.ref);

  /// Handles user sign-in with email and password.
  ///
  /// Validates the form, attempts sign-in via [AuthService],
  /// updates [AuthStatus], and navigates based on profile completion.
  Future<void> signIn(BuildContext context, GlobalKey<FormState> formKey) async {
    // Validate the input fields
    if (!formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    try {
      // Set the UI authentication status to loading
      ref.read(authStateProvider.notifier).state = AuthStatus.loading;

      // Access the AuthService notifier to call its methods
      final authService = ref.read(authServiceProvider.notifier);

      // Attempt to sign in with email and password using AuthService
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      // If sign-in is successful, update the UI authentication status to authenticated
      ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
      passwordController.clear(); // Clear sensitive password data after successful login
      debugPrint('Login successful, checking profile completion...');

      // Check if the user's profile is completed
      final isProfileComplete = await authService.isProfileCompleted();

      // Ensure the context is still mounted before attempting navigation
      if (context.mounted) {
        if (!isProfileComplete) {
          // Navigate to the profile completion screen if profile is not complete
          Navigator.pushNamedAndRemoveUntil(context, '/aboutyou', (route) => false);
          debugPrint('Navigation to /aboutyou triggered');
        } else {
          // Navigate to the main application holder screen if profile is complete
          Navigator.pushNamedAndRemoveUntil(context, '/holder', (route) => false);
          debugPrint('Navigation to /holder triggered');
        }
      } else {
        debugPrint('Context not mounted, navigation skipped');
      }
    } catch (e, st) {
      // Log any errors during sign-in
      debugPrint('SignIn error: $e\n$st');
      // Set the UI authentication status to unauthenticated on failure
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      // Show a SnackBar with the error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-In Failed: ${e.toString()}')),
        );
      }
    }
  }

  /// Handles user sign-in with Google.
  ///
  /// Attempts Google sign-in via [AuthService], updates [AuthStatus],
  /// and navigates based on profile completion.
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Set the UI authentication status to loading
      ref.read(authStateProvider.notifier).state = AuthStatus.loading;

      // Access the AuthService notifier to call its methods
      final authService = ref.read(authServiceProvider.notifier);

      // Attempt to sign in with Google using AuthService
      await authService.signInWithGoogle();

      // If sign-in is successful, update the UI authentication status to authenticated
      ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
      passwordController.clear(); // Clear any cached password data
      debugPrint('Google Sign-In successful, checking profile completion...');

      // Check if the user's profile is completed
      final isProfileComplete = await authService.isProfileCompleted();

      // Ensure the context is still mounted before attempting navigation
      if (context.mounted) {
        if (!isProfileComplete) {
          // Navigate to the profile completion screen if profile is not complete
          Navigator.pushNamedAndRemoveUntil(context, '/aboutyou', (route) => false);
          debugPrint('Navigation to /aboutyou triggered');
        } else {
          // Navigate to the main application holder screen if profile is complete
          Navigator.pushNamedAndRemoveUntil(context, '/holder', (route) => false);
          debugPrint('Navigation to /holder triggered');
        }
      } else {
        debugPrint('Context not mounted, navigation skipped');
      }
    } catch (e, st) {
      // Log any errors during Google sign-in
      debugPrint('Google SignIn error: $e\n$st');
      // Set the UI authentication status to unauthenticated on failure
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      // Show a SnackBar with the error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Failed: ${e.toString()}')),
        );
      }
    }
  }

  /// Disposes of the [TextEditingController]s to prevent memory leaks.
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}