// lib/features/auth/presentation/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'dart:async';

import '../../../../core/providers.dart'; // Adjust path
import '../../data/services/auth_service.dart'; // Adjust path
import '../controllers/auth_state_provider.dart'; // Adjust path

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // This `addPostFrameCallback` ensures the build method has run at least once,
    // allowing the splash screen UI to be painted before navigation logic starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAppInitialization();
    });
  }

  Future<void> _startAppInitialization() async {
    // 1. Ensure a minimum splash screen display time for UX.
    // This also gives the ProviderScope ample time to settle and for overrides to be active.
    await Future.delayed(const Duration(milliseconds: 1500)); // Minimum 1.5 seconds

    // 2. Perform authentication and onboarding checks.
    String nextRoute = '/signin'; // Default route

    try {
      final onboardingAsync = ref.read(onboardingCompletedProvider);
      bool isOnboardingComplete = false;

      if (onboardingAsync is AsyncData) {
        isOnboardingComplete = onboardingAsync.value ?? false;
      } else if (onboardingAsync is AsyncError) {
        debugPrint('Error loading onboarding status: ${onboardingAsync.error}');
        isOnboardingComplete = false; // Assume incomplete on error
      }

      AuthStatus authStatus = ref.read(authStateProvider); // Initial read

      // Wait for auth state to stabilize
      int attempts = 0;
      while (authStatus == AuthStatus.loading && attempts < 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        authStatus = ref.read(authStateProvider); // Re-read authStatus to get the updated value
      }
      final finalAuthStatus = authStatus; // Use the final stable status

      if (!isOnboardingComplete) {
        nextRoute = '/onboarding';
      } else if (finalAuthStatus == AuthStatus.authenticated) {
        final authService = ref.read(authServiceProvider.notifier);
        bool isProfileComplete = false;
        try {
          isProfileComplete = await authService.isProfileCompleted();
        } catch (e) {
          debugPrint('Error checking profile completion: $e');
          isProfileComplete = false; // Assume incomplete on error
        }

        if (!isProfileComplete) {
          nextRoute = '/aboutyou';
        } else {
          nextRoute = '/holder';
        }
      } else { // AuthStatus.unauthenticated or AuthStatus.error
        nextRoute = '/signin';
      }

    } catch (e, st) {
      debugPrint('Unhandled error during splash screen initialization: $e\n$st');
      nextRoute = '/signin'; // Fallback to signin on any unexpected error
    }

    // 3. Navigate only if the widget is still mounted
    if (mounted) {
      debugPrint('Navigating to: $nextRoute');
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder( // Use LayoutBuilder to get constraints for dynamic sizing
        builder: (context, constraints) {
          // Calculate logo size based on the smaller dimension (width or height)
          // to ensure it fits well in both landscape and portrait,
          // or you can stick to maxWidth for a purely width-based calculation.
          // Using min(constraints.maxWidth, constraints.maxHeight) is generally more robust.
          double baseSize = constraints.maxWidth * 0.25; // Example: 25% of screen width

          // Clamp the size to your desired min/max
          // If you want a small logo that's adaptable, this range should be considered.
          // For a small logo, 80 to 120 logical pixels is a common range.
          double logoRenderSize = baseSize.clamp(80.0, 120.0); // Clamped between 80 and 120 logical pixels

          return Center(
            child: Column( // Retain Column for vertical stacking of logo, progress indicator, and text
              mainAxisSize: MainAxisSize.min, // Make Column take minimum vertical space
              mainAxisAlignment: MainAxisAlignment.center, // Center contents vertically
              children: [
                SvgPicture.asset(
                  "assets/images/Logo_2.svg",
                  width: logoRenderSize,
                  height: logoRenderSize,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24), // Spacing below logo
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple), // Use your app's accent color
                ),
                const SizedBox(height: 16), // Spacing below indicator
                Text(
                  'Loading your perfect style...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}