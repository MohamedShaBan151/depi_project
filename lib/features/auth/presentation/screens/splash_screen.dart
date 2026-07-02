import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6A65A),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(flex: 3),

              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'NOON',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF202832),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 2,
                        color: const Color(0xFF008B5A),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'E - C O M M E R C E',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF202832),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 2,
                        color: const Color(0xFF008B5A),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 4),

              Padding(
                padding: const EdgeInsets.only(bottom: 55),
                child: Column(
                  children: [
                    const Text(
                      "Welcome to Dubai's Finest Shop",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF202832),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Delivering happiness to your doorstep',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B5B35),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(isActive: true),
                        const SizedBox(width: 7),
                        _buildDot(),
                        const SizedBox(width: 7),
                        _buildDot(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD2B86A),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Text(
                        'DUBAI, UAE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF6B5B35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({bool isActive = false}) {
    return Container(
      width: isActive ? 9 : 7,
      height: isActive ? 9 : 7,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF008B5A)
            : const Color(0xFFE5D38E),
        shape: BoxShape.circle,
      ),
    );
  }
}