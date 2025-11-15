import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/signin_screen.dart';

// A widget that guards routes based on authentication status.
// It uses Riverpod to watch the authentication state and conditionally renders
// different UIs for authenticated and unauthenticated users.
class AuthGuard extends ConsumerWidget {
  // Builder function for the UI to display when the user is authenticated.
  final WidgetBuilder authenticatedBuilder;
  // Optional builder function for the UI to display when the user is not authenticated.
  // If not provided, defaults to redirecting to the SigninScreen.
  final WidgetBuilder? unauthenticatedBuilder;

  const AuthGuard({
    super.key,
    required this.authenticatedBuilder,
    this.unauthenticatedBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the global authentication state.
    final authState = ref.watch(authStateProvider);

    if (authState == AuthStatus.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If the user is authenticated, build the UI provided by authenticatedBuilder.
    if (authState == AuthStatus.authenticated) {
      return authenticatedBuilder(context);
    }

    // If the user is not authenticated, build the UI provided by unauthenticatedBuilder,
    // or navigate to SigninScreen if unauthenticatedBuilder is null.
    return unauthenticatedBuilder?.call(context) ?? const SigninScreen();
  }
}
