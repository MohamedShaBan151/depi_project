import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noon_clone/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // Admin لا يتم إنشاؤه من Register Screen
      if (role == 'admin') {
        throw Exception('Admin account cannot be created from registration');
      }

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

        // Customer = user = active
        // Vendor = provider = pending
        'status': role == 'provider' ? 'pending' : 'active',

        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e));
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
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ================= GOOGLE SIGN IN =================
  @override
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

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
          'phone': user.phoneNumber ?? '',
          'role': 'user',
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e));
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

  // ================= CHECK SIGNED IN =================
  @override
  Future<bool> isSignedIn() async {
    return _auth.currentUser != null;
  }

  // ================= CHECK EMAIL EXISTS =================
  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email.trim());
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception(e.toString());
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