import 'package:depi_project/screens/home_screen.dart';
import 'package:depi_project/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noon_clone/features/auth/presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
          BottomNavBar.routeName: (context) => const BottomNavBar(),
      },initialRoute: BottomNavBar.routeName,
    );
  }
}

