import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  Future<void> signUp(
      String email,
      String password,
      String name, {
        String role = 'user',
        String phone = '',
      });

  Future<void> signIn(
      String email,
      String password,
      );

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<bool> checkEmailExists(String email);

  Future<String?> getUserRole(String uid);
}