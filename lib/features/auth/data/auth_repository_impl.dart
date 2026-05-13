import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  bool get isEmailVerified;
  User? get currentUser;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  @override
  Future<void> signUp(String email, String password, String name) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(name);
      await result.user?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email format';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-not-found':
        return 'No user found';
      case 'wrong-password':
        return 'Wrong password';
      case 'operation-not-allowed':
        return 'Enable Email/Password in Firebase';
      case 'network-request-failed':
        return 'Check your internet connection';
      default:
        return e.message ?? 'Something went wrong';
    }
  }
}
