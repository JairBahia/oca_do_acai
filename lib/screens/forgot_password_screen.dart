// RF003 – Recuperação de Senha
import 'package:flutter/material.dart';
import '../app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _enviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(v.trim())) return 'E-mail inválido';
    return null;
  }

  Future<void> _recuperarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _enviado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: _enviado ? _buildSucessoUI() : _buildFormUI(),
        ),
      ),
    );
  }

  Widget _buildFormUI() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 72,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Esqueceu sua senha?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Informe seu e-mail e enviaremos\nas instruções de recuperação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _recuperarSenha(),
            decoration: const InputDecoration(
              labelText: 'E-mail cadastrado',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: _validarEmail,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _recuperarSenha,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enviar instruções'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar para o login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSucessoUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: AppTheme.successColor,
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'E-mail enviado!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Verifique sua caixa de entrada em\n${_emailController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
        const SizedBox(height: 36),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar para o login'),
        ),
      ],
    );
  }
}
