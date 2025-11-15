import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/auth_service.dart';


// Define the authentication status for UI consumption
enum AuthStatus {
  loading, // Initial state, checking authentication
  authenticated,
  unauthenticated,
}

// A StateProvider that exposes the current authentication status for UI components.
final authStateProvider = StateProvider<AuthStatus>((ref) {
  // Watch the actual AuthService's state (AuthStatus enum from auth_service.dart)
  final authServiceState = ref.watch(authServiceProvider);

  // Map the AuthService's AuthStatus to the UI-friendly AuthStatus
  // Ensure all cases are explicitly handled or add a default case.
  switch (authServiceState) {
    case AuthStatus.loading:
      return AuthStatus.loading;
    case AuthStatus.authenticated:
      return AuthStatus.authenticated;
    case AuthStatus.unauthenticated:
      return AuthStatus.unauthenticated;
  // Adding a default case or an assert to satisfy exhaustive checking.
  // A default case is generally safer for future-proofing enums.
  // If you add a new enum value later, this default will catch it,
  // though you might want a lint to remind you to add a specific case.
  // For now, this is a clean way to handle it.
  // A throw UnsupportedError is also common for "should not happen" scenarios.
    default:
    // This case should theoretically not be reached if AuthStatus from auth_service.dart
    // and this AuthStatus enum are identical and exhaustive.
    // However, the linter doesn't know that for sure at compile time.
    // We can return a sensible default or throw an error.
    // Returning loading is often a safe fallback.
      return AuthStatus.loading; // Or throw UnsupportedError('Unhandled AuthStatus: $authServiceState');
  }
});