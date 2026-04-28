import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noon_clone/features/auth/presentation/screens/splash_screen.dart';

import 'firebase_options.dart';

import 'core/theme/saudi_theme.dart';
import 'core/router/app_router.dart';

import 'cubits/shopping_cubit.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/products/data/product_service.dart';
import 'features/products/presentation/cubit/product_cubit.dart';
import 'features/products/presentation/cubit/order_cubit.dart';

// 👇 إضافة السplash
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(SaudiTheme.overlayStyle);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const NoonApp());
}

class NoonApp extends StatelessWidget {
  const NoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ShoppingCubit()),

        BlocProvider(
          create: (_) => ProductCubit(ProductService())..loadProducts(),
        ),

        BlocProvider(
          create: (_) => AuthCubit(AuthRepositoryImpl()),
        ),

        BlocProvider(create: (_) => OrderCubit()),
      ],
      child: MaterialApp.router(
        title: 'Noon SA',
        debugShowCheckedModeBanner: false,
        theme: SaudiTheme.theme,

        //تم التعديل هنا
        // // ✅ دي أهم سطر
        // builder: (context, child) {
        //   return const SplashScreen();
        // },

        routerConfig: appRouter,
      ),
    );
  }
}