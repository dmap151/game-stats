import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class SupabaseService {
  SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => clientOrNull?.auth.currentUser;

  Stream<AuthState> get onAuthStateChange =>
      clientOrNull?.auth.onAuthStateChange ?? const Stream.empty();

  bool get isAuthenticated => currentUser != null;

  /// Initializes Supabase. Call this in main() before runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      // ignore: deprecated_member_use
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Sign in with Email and Password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register a new account with Email and Password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  /// Native Google Sign-In on mobile/web using GoogleSignIn and Supabase signInWithIdToken.
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.googleWebClientId,
        scopes: const ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Kein ID Token von Google erhalten.');
      }

      return await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign out from both Supabase and Google.
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.googleWebClientId,
      );
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint('Google signOut error (harmless): $e');
    }

    await client.auth.signOut();
  }
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();
  @override
  String toString() => 'Anmeldung abgebrochen.';
}
