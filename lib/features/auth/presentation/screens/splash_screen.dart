import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/saudi_theme.dart';

/// Splash screen.
///
/// FIX: the original always redirected to /register regardless of auth state.
/// Now it checks FirebaseAuth for an existing session and routes to '/'
/// (home) when already signed in, or '/register' when not.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2, milliseconds: 500), () {
        if (!mounted) return;
        final user = FirebaseAuth.instance.currentUser;
        // Route to home if already signed in, else to register
        context.go(user != null ? '/' : '/register');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Noon Clone',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Shopping App',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
