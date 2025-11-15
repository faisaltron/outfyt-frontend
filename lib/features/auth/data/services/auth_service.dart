import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_fashion_app/core/config/api_config.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/network/api_client.dart';
import '../../../../core/providers.dart';
import '../../presentation/controllers/auth_state_provider.dart';

// --- Provider for AuthService ---
final authServiceProvider = StateNotifierProvider<AuthService, AuthStatus>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(
    apiClient: apiClient,
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  );
});

/// Service class for handling authentication with both Firebase and Django
class AuthService extends StateNotifier<AuthStatus> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final ApiClient _apiClient;
  DateTime? _tokenExpiry;

  AuthService({
    required ApiClient apiClient,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _apiClient = apiClient,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(AuthStatus.loading) {
    _initializeAuth();
  }

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool get _needsTokenRefresh {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }

  Future<void> _initializeAuth() async {
    final initialDjangoToken = _apiClient.getAccessToken();
    debugPrint('[AuthService] Initializing Auth. Token from prefs: ${initialDjangoToken != null ? 'Present' : 'null'}');

    if (initialDjangoToken != null && initialDjangoToken.isNotEmpty) {
      state = AuthStatus.authenticated;
      try {
        await ensureValidToken();
      } catch (e) {
        debugPrint('[AuthService] Token validation/refresh failed on init: $e');
        await _apiClient.clearAuthTokens();
        state = AuthStatus.unauthenticated;
      }
    } else {
      state = AuthStatus.unauthenticated;
    }

    _firebaseAuth.authStateChanges().listen((user) async {
      debugPrint('[AuthService] Firebase Auth State Change: User is ${user != null ? 'present' : 'null'}');
      if (user == null) {
        await _apiClient.clearAuthTokens();
        _tokenExpiry = null;
        state = AuthStatus.unauthenticated;
      } else {
        await _ensureDjangoTokenAfterFirebaseLogin(user);
      }
    });
  }

  // --- Helper to get/set Django token after Firebase login ---
  Future<void> _ensureDjangoTokenAfterFirebaseLogin(User user) async {
    debugPrint('[AuthService] Ensuring Django token after Firebase login for user: ${user.uid}');
    final currentDjangoToken = _apiClient.getAccessToken();

    if (currentDjangoToken == null || currentDjangoToken.isEmpty || _needsTokenRefresh) {
      try {
        final firebaseToken = await user.getIdToken(true);
        debugPrint('[AuthService] Firebase ID Token acquired for Django exchange.');
        final response = await _apiClient.post(
          ApiConfig.firebaseLogin, // <--- CORRECTED THIS LINE
          {'firebase_token': firebaseToken},
        );
        await _apiClient.setAuthTokens(response['access'], refreshToken: response['refresh']);
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
        state = AuthStatus.authenticated;
        debugPrint('[AuthService] Django token successfully obtained and set.');
      } catch (e) {
        debugPrint('[AuthService] Failed to get/refresh Django token after Firebase login: $e');
        await _apiClient.clearAuthTokens();
        _tokenExpiry = null;
        state = AuthStatus.unauthenticated;
        rethrow;
      }
    } else {
      debugPrint('[AuthService] Existing Django token is valid.');
      state = AuthStatus.authenticated;
    }
  }

  Future<void> _refreshTokens() async {
    debugPrint('[AuthService] Attempting to refresh tokens...');
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        await _apiClient.clearAuthTokens();
        _tokenExpiry = null;
        state = AuthStatus.unauthenticated;
        throw Exception('No user logged in to refresh token');
      }

      final currentRefreshToken = _apiClient.getRefreshToken();
      if (currentRefreshToken == null) {
        debugPrint('[AuthService] No refresh token available. Cannot refresh.');
        await _apiClient.clearAuthTokens();
        _tokenExpiry = null;
        state = AuthStatus.unauthenticated;
        throw Exception('No refresh token available to renew session.');
      }

      final response = await _apiClient.post(
        ApiConfig.refreshToken,
        {'refresh': currentRefreshToken},
      );

      await _apiClient.setAuthTokens(response['access'], refreshToken: response['refresh']);
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
      state = AuthStatus.authenticated;
      debugPrint('[AuthService] Tokens refreshed and state updated to authenticated.');
    } catch (e) {
      debugPrint('[AuthService] Token refresh failed: $e');
      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;
      state = AuthStatus.unauthenticated;
      throw _handleError(e);
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    state = AuthStatus.loading;
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // After successful Firebase email/password sign-in, get Django token
        await _ensureDjangoTokenAfterFirebaseLogin(userCredential.user!);
      } else {
        throw Exception('Firebase user is null after sign-in.');
      }
      return userCredential;
    } catch (e) {
      debugPrint('[AuthService] Sign in failed: $e');
      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;
      state = AuthStatus.unauthenticated;
      throw _handleError(e);
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    state = AuthStatus.loading;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = AuthStatus.unauthenticated;
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // After successful Google sign-in via Firebase, get Django token
        await _ensureDjangoTokenAfterFirebaseLogin(userCredential.user!);
      } else {
        throw Exception('Firebase user is null after Google sign-in.');
      }
      return userCredential;
    } catch (e) {
      debugPrint('[AuthService] Google sign in failed: $e');
      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;
      state = AuthStatus.unauthenticated;
      throw _handleError(e);
    }
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = AuthStatus.loading;
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        final firebaseToken = await firebaseUser.getIdToken(true);

        debugPrint('[AuthService] Firebase user registered: ${firebaseUser.uid}');

        // Send Firebase token and initial profile data (name) to Django backend
        // NOTE: This call to ApiConfig.register needs to ensure your Django register endpoint
        // is set up to receive a 'firebase_token', 'email', and 'name'.
        // If your Django RegisterView doesn't support 'firebase_token' directly,
        // you might need to send this to ApiConfig.firebaseLogin instead,
        // as FirebaseLoginView will handle user creation/retrieval based on the Firebase token.
        final response = await _apiClient.post(
          ApiConfig.firebaseLogin,
          {
            'firebase_token': firebaseToken,
            'email': email,
            'name': name,
          },
        );

        await _apiClient.setAuthTokens(
            response['access'], refreshToken: response['refresh']);
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));

        state = AuthStatus.authenticated;
        debugPrint('[AuthService] User registered and initial profile data sent to Django.');
      } else {
        throw Exception('Firebase user is null after registration.');
      }
      return userCredential;
    } catch (e) {
      debugPrint('[AuthService] Registration failed: $e');
      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;
      state = AuthStatus.unauthenticated;
      throw _handleError(e);
    }
  }

  Future<void> signOut() async {
    debugPrint('[AuthService] Signing out...');
    state = AuthStatus.loading;
    final String? refreshToken = _apiClient.getRefreshToken(); // Get the refresh token

    try {
      try {
        await _apiClient.post(ApiConfig.logout, {'refresh': refreshToken});

      } catch (e) {
        debugPrint('[AuthService] Failed to notify backend of logout: $e');
      }

      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;

      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      state = AuthStatus.unauthenticated;
      debugPrint('[AuthService] Signed out successfully.');
    } catch (e) {
      debugPrint('[AuthService] Sign out failed: $e');
      await _apiClient.clearAuthTokens();
      _tokenExpiry = null;
      state = AuthStatus.unauthenticated;
      throw _handleError(e);
    }
  }


  Future<void> ensureValidToken() async {
    final currentToken = _apiClient.getAccessToken();
    if (currentToken == null || currentToken.isEmpty) {
      debugPrint('[AuthService] No Django token found, skipping refresh.');
      state = AuthStatus.unauthenticated;
      return;
    }

    if (_needsTokenRefresh) {
      debugPrint('[AuthService] Token refresh needed. Attempting refresh.');
      try {
        await _refreshTokens();
        debugPrint('[AuthService] Token refreshed and valid.');
      } catch (e) {
        debugPrint('[AuthService] Failed to refresh token in ensureValidToken: $e');
        state = AuthStatus.unauthenticated;
        await _apiClient.clearAuthTokens();
        rethrow;
      }
    } else {
      debugPrint('[AuthService] Token is valid. No refresh needed.');
      state = AuthStatus.authenticated;
    }
  }

  Future<bool> isProfileCompleted() async {
    try {
      await ensureValidToken();
      final response = await _apiClient.get(ApiConfig.userProfile);
      debugPrint('[AuthService] Profile data received: $response');

      final bool hasGender = response['gender'] != null && (response['gender'] as String).isNotEmpty;
      final bool hasStylePreferences = response['style_preferences'] != null && (response['style_preferences'] as List).isNotEmpty;

      return hasGender && hasStylePreferences;
    } on ApiException catch (e) {
      debugPrint('[AuthService] ApiException checking profile completion: ${e.message}');
      _handleError(e);
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Error checking profile completion: $e');
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    debugPrint('[AuthService] Onboarding would be marked complete here. Implement LocalStorageService call.');
    // TODO: Call LocalStorageService.setOnboardingComplete(true);
  }

  Exception _handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return Exception('No user found with this email.');
        case 'wrong-password':
          return Exception('Wrong password provided.');
        case 'email-already-in-use':
          return Exception('Email is already in use.');
        case 'invalid-email':
          return Exception('Email address is invalid.');
        case 'weak-password':
          return Exception('Password is too weak.');
        default:
          return Exception(error.message ?? 'An authentication error occurred.');
      }
    } else if (error is ApiException) {
      if (error.statusCode == 401) {
        debugPrint('[AuthService] API 401 received: ${error.message}. Clearing tokens and setting unauthenticated.');
        _apiClient.clearAuthTokens();
        _tokenExpiry = null;
        state = AuthStatus.unauthenticated;
        return Exception('Session expired or invalid token. Please sign in again.');
      }
      return Exception('API Error: ${error.message}');
    }
    return Exception(error.toString());
  }
}