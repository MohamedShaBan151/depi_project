import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/products/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/checkout_screen.dart';
import '../../features/products/presentation/screens/order_confirmation_screen.dart';
import '../../features/products/presentation/screens/order_history_screen.dart';

// FIX: removed ShellRoute + MainShell that was adding a SECOND BottomNavigationBar
// on top of the NoonBottomNav already rendered inside HomeScreen's IndexedStack.
// HomeScreen is self-contained (manages its own tabs + NoonBottomNav).
// Deep-link routes (/products/:id, /checkout, /orders) push on top of it without a shell.
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Main shell: HomeScreen owns its own bottom nav ─────────────────────
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),

    // ── Auth routes ────────────────────────────────────────────────────────
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    // ── Deep-link product / order routes ────────────────────────────────────
    GoRoute(
      path: '/products/:id',
      builder: (context, state) => ProductDetailsScreen(
        productId: state.pathParameters['id'] ?? '',
      ),
    ),

    GoRoute(
      path: '/checkout',
      builder: (_, __) => const CheckoutScreen(),
    ),

    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrderHistoryScreen(),
    ),

    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) => OrderConfirmationScreen(
        orderId: state.uri.queryParameters['orderId'] ?? '',
        total: double.tryParse(state.uri.queryParameters['total'] ?? '0') ?? 0,
      ),
    ),
  ],
);
