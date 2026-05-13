import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/saudi_theme.dart';

/// Auto-advancing hero banner carousel (mock data).
class HeroBannerCarousel extends StatefulWidget {
  const HeroBannerCarousel({super.key});

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  static const _banners = [
    _Banner('Up to 50% Off Electronics', '🎧', AppColors.darkGreen),
    _Banner('Flash Sale — Noon Yellow Friday', '⚡', Color(0xFF8B0000)),
    _Banner('Free Delivery on Groceries', '🛒', Color(0xFF006C35)),
  ];

  final _controller = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _current = (_current + 1) % _banners.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) => _BannerTile(banner: _banners[i]),
          ),
          // Dots indicator
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _current == i ? AppColors.primary : Colors.white60,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner {
  final String title;
  final String emoji;
  final Color color;
  const _Banner(this.title, this.emoji, this.color);
}

class _BannerTile extends StatelessWidget {
  final _Banner banner;
  const _BannerTile({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: banner.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(banner.emoji, style: const TextStyle(fontSize: 52)),
          ),
        ],
      ),
    );
  }
}
