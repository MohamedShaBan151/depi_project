import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository_impl.dart';

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User? user;
  AuthAuthenticated([this.user]);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repo;

  AuthCubit(this.repo) : super(AuthInitial());

  // ================= SIGN UP =================
  Future<void> signUp(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      await repo.signUp(email, password, name);

      await _refreshUser();

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= SIGN IN =================
  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await repo.signIn(email, password);

      await _refreshUser();

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= GOOGLE SIGN IN =================
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await repo.signInWithGoogle();

      await _refreshUser();

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    await repo.signOut();
    emit(AuthInitial());
  }

  // ================= FIX IMPORTANT =================
  Future<void> _refreshUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = repo.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError("User not found after login"));
    }
  }
}