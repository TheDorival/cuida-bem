import 'package:firebase_auth/firebase_auth.dart';

/// Servico de autenticacao (UC001) sobre o Firebase Auth.
/// Fornece login, cadastro e o ID token usado pelo back-end (Bearer).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;
  Stream<User?> get mudancas => _auth.authStateChanges();

  Future<User> entrar(String email, String senha) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: senha);
    return cred.user!;
  }

  Future<User> cadastrar(String nome, String email, String senha) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
    await cred.user!.updateDisplayName(nome);
    return cred.user!;
  }

  /// ID token do Firebase enviado ao back-end e validado via verifyIdToken.
  Future<String?> idToken({bool forcar = false}) => _auth.currentUser?.getIdToken(forcar) ?? Future.value(null);

  Future<void> sair() => _auth.signOut();
}
