import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentSession != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Login com e-mail e senha
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Cadastro com e-mail e senha
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  // Login com Google OAuth
  Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Uri.base.origin,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
