// RF001 – Login
import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'forgot_password_screen.dart';
import 'menu_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscureSenha = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Validação de e-mail (RF001)
  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  // Validação de senha (RF001)
  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    return null;
  }

  // Simula autenticação 
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); 

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ──Imagem do Estabelecimento ──────────────
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_dining,
                      color: Colors.white,
                      size: 64,
                    ),
                    
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Oca do Açaí',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Faça login para continuar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Formulário ────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo E-mail
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: _validarEmail,
                      ),

                      const SizedBox(height: 16),

                      // Campo Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscureSenha,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _entrar(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureSenha
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscureSenha = !_obscureSenha),
                          ),
                        ),
                        validator: _validarSenha,
                      ),

                      const SizedBox(height: 8),

                      // Link Esqueceu a senha
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const ForgotPasswordScreen()),
                          ),
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botão Entrar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _entrar,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
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

                const SizedBox(height: 24),

                // Link para Cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Não tem conta? '),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Cadastre-se'),
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
