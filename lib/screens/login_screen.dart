import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _bg = Color(0xFF0F0F1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final response = await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.session != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on AuthException catch (e) {
      _showError(_mapAuthError(e.message));
    } catch (e) {
      _showError('Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithGoogle();
      // O Supabase redireciona via OAuth; aguarda o listener
    } catch (e) {
      _showError('Erro ao entrar com Google: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    return message;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                // ── Logo / Header ──────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_esports,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'GameRank',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Avalie e descubra os melhores jogos',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Formulário ─────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A4A)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Entrar',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // E-mail
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon:
                                Icon(Icons.email_outlined, color: Colors.white54),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe o e-mail';
                            }
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Senha
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe a senha';
                            }
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Botão Login
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signIn,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Divisor ────────────────────────────────
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: Color(0xFF2A2A4A), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ou',
                          style: GoogleFonts.poppins(
                              color: Colors.white38, fontSize: 13)),
                    ),
                    const Expanded(
                        child: Divider(color: Color(0xFF2A2A4A), thickness: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Login com Google ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _signInWithGoogle,
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, size: 20),
                    ),
                    label: Text(
                      'Entrar com Google',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2A4A)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Link cadastro ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Não tem conta? ',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text(
                        'Cadastre-se',
                        style: GoogleFonts.poppins(
                          color: _purple,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
