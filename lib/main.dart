import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Keep this for Riverpod
import 'package:firebase_core/firebase_core.dart'; // Keep this for Firebase
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers.dart';
import 'features/auth/presentation/controllers/auth_state_provider.dart'; // For AuthState
import 'core/theme/theme.dart';
import 'core/widgets/auth_guard.dart';
import 'features/auth/presentation/screens/forget_password_screen.dart';
import 'features/auth/presentation/screens/personalization_splash_screen.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/recommendations/presentation/recommendation_screen.dart';
import 'features/mylooks/my_looks_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/profile/about_you_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/shared/holder_screen.dart';
import 'features/wardrobe/presentation/wardrobe_screen.dart';

// Corrected import path for RecommendationScreen:
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences ONCE
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app within a ProviderScope to enable Riverpod state management.
  runApp(
    ProviderScope(
      overrides: [
        // Provide the single initialized SharedPreferences instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication status to determine the initial route and guard protected routes.
    final authStatus = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Consider defining more theme properties for consistency (e.g., text themes, button themes).
      ),
      // Set the initial route of the application.
      initialRoute: '/',
      // Use onGenerateRoute for dynamic route generation and centralized navigation logic.
      onGenerateRoute: (settings) => _generateRoute(settings, authStatus),
    );
  }

  // Generates routes based on the route settings and authentication status.
  Route<dynamic> _generateRoute(RouteSettings settings, AuthStatus authStatus) {
    // Always show SplashScreen for the initial route
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
        settings: settings, // Pass settings for route observers or analytics
      );
    }

    // Check if the requested route is protected.
    if (_isProtectedRoute(settings.name)) {
      // For protected routes, use AuthGuard to ensure the user is authenticated.
      return MaterialPageRoute(
        builder: (_) => AuthGuard(
          // If authenticated, navigate to the requested protected screen.
          authenticatedBuilder: (_) => _getProtectedScreen(settings.name!),
          // If not authenticated, redirect to the sign-in screen.
          unauthenticatedBuilder: (_) => const SigninScreen(),
        ),
        settings: settings,
      );
    }

    // For public routes, navigate directly to the screen.
    return MaterialPageRoute(
      builder: (_) => _getPublicScreen(settings.name),
      settings: settings,
    );
  }

  // Determines if a given route name is a protected route.
  bool _isProtectedRoute(String? routeName) {
    const protectedRoutes = [
      '/profile',
      '/home',
      '/aboutyou',
      '/holder',
      '/wardrobe',
      '/mylooks',
      '/recommendation'
      // Add other protected routes here.
    ];
    return protectedRoutes.contains(routeName);
  }

  // Returns the appropriate widget for a given protected route name.
  Widget _getProtectedScreen(String route) {
    switch (route) {
      case '/profile':
        return const ProfileScreen();
      case '/home':
        return const HomeScreen();
      case '/aboutyou':
        return const AboutYouScreen();
      case '/holder':
        return const HolderScreen(); // This likely holds main app navigation (e.g. BottomNavBar)
      case '/wardrobe':
        return const WardrobeScreen();
      case '/mylooks':
        return const MyLooksScreen();
      case '/recommendation':
        return const RecommendationScreen();
      default:
      // Fallback for unknown protected routes, could redirect to a 404 page or home.
        return const SigninScreen();
    }
  }

  // Returns the appropriate widget for a given public route name.
  Widget _getPublicScreen(String? route) {
    switch (route) {
      case '/signin':
        return const SigninScreen();
      case '/signup':
        return const SignupScreen();
      case '/onboarding':
        return const OnboardingScreen();
      case '/forgetpassword':
        return const ForgetPasswordScreen();
      case '/personalizationsplash':
        return const PersonalizationSplashScreen();
      default:
      // Fallback for unknown public routes or initial splash screen.
        return const SplashScreen();
    }
  }
}