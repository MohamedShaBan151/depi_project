import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();

  Future<void> signUp(
      String email,
      String password,
      String name, {
        String role = 'user',
        String phone = '',
      });

  Future<String?> getUserRole(String uid);

  Future<void> signOut();

  User? get currentUser;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ مهم جدًا Android + iOS
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  User? get currentUser => _auth.currentUser;

  // ================= SIGN UP =================
  @override
  Future<void> signUp(
      String email,
      String password,
      String name, {
        String role = 'user',
        String phone = '',
      }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user;

      if (user == null) {
        throw Exception('User not found after sign up');
      }

      await user.updateDisplayName(name.trim());
      await user.reload();

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ================= SIGN IN =================
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // ================= GOOGLE SIGN IN =================
  @override
  Future<void> signInWithGoogle() async {
    try {
      // ❗ مهم: reset session (fix مشاكل login عالقة)
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // user cancel
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Missing Google auth tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      final user = result.user;

      if (user == null) {
        throw Exception('User not found after Google sign in');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': '',
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ================= GET USER ROLE =================
  @override
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();

      return data?['role'] as String?;
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  // ================= SIGN OUT =================
  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ================= ERROR HANDLING =================
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
      case 'invalid-credential':
        return 'Email or password is incorrect';
      case 'operation-not-allowed':
        return 'Enable Email/Password in Firebase';
      case 'network-request-failed':
        return 'Check your internet connection';
      default:
        return e.message ?? 'Something went wrong';
    }
  }
}