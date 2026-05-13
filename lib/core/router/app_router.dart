import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/products/presentation/screens/home_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/checkout_screen.dart';
import '../../features/products/presentation/screens/order_confirmation_screen.dart';
import '../../features/products/presentation/screens/order_history_screen.dart';
import '../../features/products/presentation/screens/addresses_screen.dart';
import '../../features/products/presentation/screens/cart_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
      path: '/addresses',
      builder: (_, __) => const AddressesScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (_, __) => const CartScreen(),
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
