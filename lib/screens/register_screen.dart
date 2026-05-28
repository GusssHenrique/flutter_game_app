import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  static const Color _purple = Color(0xFF6C63FF);
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _bg = Color(0xFF0F0F1A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final response = await _authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        // Se confirmação de e-mail estiver desativada no Supabase, loga direto
        if (response.session != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
          );
        } else {
          _showSuccess(
              'Cadastro realizado! Verifique seu e-mail para confirmar.');
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      _showError(_mapError(e.message));
    } catch (e) {
      _showError('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapError(String msg) {
    if (msg.contains('already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('Password should be')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return msg;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_add,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),
                Text('Criar conta',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                const SizedBox(height: 6),
                Text('Junte-se à comunidade GameRank',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.white54)),
                const SizedBox(height: 32),

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
                        // E-mail
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.white54),
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
                          obscureText: _obscurePass,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
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
                        const SizedBox(height: 14),

                        // Confirmar senha
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.white54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirme a senha';
                            }
                            if (v != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signUp,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Criar conta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem conta? ',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Entrar',
                          style: GoogleFonts.poppins(
                            color: _purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
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
