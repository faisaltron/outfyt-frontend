// File: lib/features/auth/presentation/controllers/signup_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_fashion_app/features/auth/presentation/controllers/auth_state_provider.dart';

import '../../data/services/auth_service.dart';

// These controllers will be watched by the UI widgets directly.
// They are autoDispose so they clean up when the SignupScreen is removed.
final nameControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final emailControllerProvider = Provider.autoDispose((ref) => TextEditingController());
final passwordControllerProvider = Provider.autoDispose((ref) => TextEditingController());
// final genderControllerProvider = Provider.autoDispose((ref) => TextEditingController()); // REMOVE THIS LINE


final signupControllerProvider = Provider.autoDispose((ref) {
  return SignupController(
    ref: ref,
    nameController: ref.watch(nameControllerProvider),
    emailController: ref.watch(emailControllerProvider),
    passwordController: ref.watch(passwordControllerProvider),
    // genderController: ref.watch(genderControllerProvider), // REMOVE THIS LINE
    authService: ref.watch(authServiceProvider.notifier),
  );
});

class SignupController {
  final Ref ref;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  // final TextEditingController genderController; // REMOVE THIS LINE
  final AuthService authService;

  SignupController({
    required this.ref,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    // required this.genderController, // REMOVE THIS LINE
    required this.authService,
  });

  Future<void> submit(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    try {
      ref.read(authStateProvider.notifier).state = AuthStatus.loading;

      await authService.register(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
      );

      ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
      passwordController.clear(); // Clear sensitive data

      final isProfileComplete = await authService.isProfileCompleted();
      if (context.mounted) {
        if (!isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, '/aboutyou', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/holder', (route) => false);
        }
      }
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      ref.read(authStateProvider.notifier).state = AuthStatus.loading;
      await authService.signInWithGoogle();

      ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;
      passwordController.clear();

      final isProfileComplete = await authService.isProfileCompleted();
      if (context.mounted) {
        if (!isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, '/aboutyou', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/holder', (route) => false);
        }
      }
    } catch (e) {
      ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-Up Failed: ${e.toString()}')),
        );
      }
    }
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    // Removed: genderController.dispose(); // Ensure this line is gone
  }
}