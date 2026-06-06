import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream que emite o usuário atual sempre que o estado de autenticação muda.
  /// Emite null quando não há usuário logado.
  Stream<User?> get userStream => _auth.authStateChanges();

  /// Retorna o usuário atualmente autenticado (ou null).
  User? get currentUser => _auth.currentUser;

  /// Login com e-mail e senha.
  /// Lança [FirebaseAuthException] em caso de erro.
  Future<UserCredential> signIn(String email, String senha) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  /// Cadastro com e-mail e senha.
  /// Lança [FirebaseAuthException] em caso de erro.
  Future<UserCredential> signUp(String email, String senha) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  /// Envia e-mail de recuperação de senha.
  /// Lança [FirebaseAuthException] em caso de erro.
  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Faz logout do usuário atual.
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Traduz os códigos de erro do Firebase para mensagens em português.
  static String mensagemErro(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'invalid-email':
        return 'Formato de e-mail inválido.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}