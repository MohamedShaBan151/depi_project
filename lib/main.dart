import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'core/theme/saudi_theme.dart';
import 'core/router/app_router.dart';
import 'cubits/shopping_cubit.dart';
import 'data/data_sources/cart_persistence_service.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/products/data/product_service.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/products/presentation/cubit/order_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise SharedPreferences once at startup and pass it down.
  final prefs = await SharedPreferences.getInstance();
  final cartPersistence = CartPersistenceService(prefs);

  SystemChrome.setSystemUIOverlayStyle(SaudiTheme.overlayStyle);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(NoonApp(cartPersistence: cartPersistence));
}

class NoonApp extends StatelessWidget {
  final CartPersistenceService cartPersistence;

  const NoonApp({super.key, required this.cartPersistence});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          // Rehydrate cart immediately after creation.
          create: (_) =>
              ShoppingCubit(cartPersistence)..loadPersistedCart(),
        ),
        BlocProvider(
          create: (_) => ProductCubit(ProductService())..loadProducts(),
        ),
        BlocProvider(create: (_) => AuthCubit(AuthRepositoryImpl())),
        BlocProvider(create: (_) => OrderCubit()),
      ],
      child: MaterialApp.router(
        title: 'Noon SA',
        debugShowCheckedModeBanner: false,
        theme: SaudiTheme.theme,
        routerConfig: appRouter,
      ),
    );
  }
}
