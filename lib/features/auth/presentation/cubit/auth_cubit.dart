import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noon_clone/notifications/notification_service.dart';
import 'package:noon_clone/features/auth/domain/auth_repository.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String role;

  AuthAuthenticated({
    required this.user,
    required this.role,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;

  AuthCubit(this.repo) : super(AuthInitial());

  // ================= SIGN UP =================
  Future<void> signUp(
    String email,
    String password,
    String name, {
    String role = 'user',
    String phone = '',
  }) async {
    emit(AuthLoading());

    try {
      // Admin لا يتم إنشاؤه من Register Screen
      if (role == 'admin') {
        emit(AuthError('Admin account cannot be created from registration.'));
        return;
      }

      await repo.signUp(
        email,
        password,
        name,
        role: role,
        phone: phone,
      );

      await _refreshUser();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  // ================= SIGN IN =================
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());

    try {
      await repo.signIn(email, password);

      await _refreshUser();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  // ================= GOOGLE SIGN IN =================
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      await repo.signInWithGoogle();

      await _refreshUser();
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    try {
      await repo.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(_cleanError(e)));
    }
  }

  // ================= GET USER + ROLE =================
  Future<void> _refreshUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = repo.currentUser;

    if (user == null) {
      emit(AuthError('User not found after login'));
      return;
    }

    final role = await repo.getUserRole(user.uid);

    if (role == null || role.isEmpty) {
      emit(AuthError('User role not found'));
      return;
    }

    // تسجيل FCM Token لا يجب أن يمنع الدخول لو حصل فيه خطأ
    try {
      await NotificationService.registerAndSaveToken();
    } catch (_) {}

    emit(
      AuthAuthenticated(
        user: user,
        role: role,
      ),
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
