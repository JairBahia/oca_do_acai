// RF002 – Cadastro de Usuário
import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'menu_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();
  bool _obscureSenha = true;
  bool _obscureConfirmacao = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  String? _validarNome(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o nome';
    return null;
  }

  String? _validarEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(v.trim())) return 'E-mail inválido';
    return null;
  }

  String? _validarTelefone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o telefone';
    return null;
  }

  String? _validarSenha(String? v) {
    if (v == null || v.isEmpty) return 'Informe a senha';
    if (v.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validarConfirmacao(String? v) {
    if (v == null || v.isEmpty) return 'Confirme a senha';
    if (v != _senhaController.text) return 'As senhas não coincidem';
    return null;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Feedback de sucesso ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado com sucesso! Bem-vindo(a)!'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    // Navega para o cardápio após cadastro
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Preencha seus dados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Nome
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validarNome,
                ),
                const SizedBox(height: 14),

                // E-mail
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
                const SizedBox(height: 14),

                // Telefone
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Número de telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '(11) 99999-9999',
                  ),
                  validator: _validarTelefone,
                ),
                const SizedBox(height: 14),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscureSenha,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureSenha
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscureSenha = !_obscureSenha),
                    ),
                  ),
                  validator: _validarSenha,
                ),
                const SizedBox(height: 14),

                // Confirmação de senha
                TextFormField(
                  controller: _confirmacaoController,
                  obscureText: _obscureConfirmacao,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _cadastrar(),
                  decoration: InputDecoration(
                    labelText: 'Confirmação de senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmacao
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscureConfirmacao = !_obscureConfirmacao),
                    ),
                  ),
                  validator: _validarConfirmacao,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Criar Conta'),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem conta? '),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fazer login'),
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
