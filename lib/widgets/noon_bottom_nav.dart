import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  NoonBottomNav – drop-in animated bottom nav
//  Reproduces noon_bottom_nav_4.html spring curves
//  using AnimationController + CurvedAnimation.
// ─────────────────────────────────────────────

/// A bottom navigation bar with:
///  • Yellow pill background that springs in on the active item
///  • Active icon bounces up with elastic overshoot
///  • Active label fades + slides up
///  • Inactive icons lift on hover (desktop) / press (mobile)
///  • Cart badge with animated border colour on active
class NoonBottomNav extends StatefulWidget {
  const NoonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadge,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Number shown on the cart badge. Pass null to hide it.
  final int? cartBadge;

  @override
  State<NoonBottomNav> createState() => _NoonBottomNavState();
}

class _NoonBottomNavState extends State<NoonBottomNav>
    with TickerProviderStateMixin {
  late final List<_NoonItemController> _controllers;

  static const _items = [
    _NavItem(label: 'Home',    icon: _NavIcon.home),
    _NavItem(label: 'Search',  icon: _NavIcon.search),
    _NavItem(label: 'Cart',    icon: _NavIcon.cart),
    _NavItem(label: 'Account', icon: _NavIcon.account),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _items.length,
      (i) => _NoonItemController(vsync: this, active: i == widget.currentIndex),
    );
  }

  @override
  void didUpdateWidget(NoonBottomNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _controllers[old.currentIndex].deactivate();
      _controllers[widget.currentIndex].activate();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 80 + bottomPad,
      decoration: const BoxDecoration(
        color: Color(0xFF1F1F23),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2D))),
      ),
      padding: EdgeInsets.only(left: 4, right: 4, bottom: 8 + bottomPad),
      child: Row(
        children: List.generate(_items.length, (i) {
          return Expanded(
            child: _NoonNavItem(
              item: _items[i],
              controller: _controllers[i],
              badge: i == 2 ? widget.cartBadge : null,
              onTap: () => widget.onTap(i),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Per-item animation controller
// ─────────────────────────────────────────────

class _NoonItemController {
  _NoonItemController({required TickerProvider vsync, required bool active}) {
    _pillCtrl = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 460));
    _pillScale =
        CurvedAnimation(parent: _pillCtrl, curve: const _BackOutCurve(2.2));
    _pillOpacity =
        CurvedAnimation(parent: _pillCtrl, curve: Curves.easeOut);

    _iconCtrl = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 500));
    _iconY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -7)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -7, end: -5)
            .chain(CurveTween(curve: const _ElasticOutCurve(1.0, 0.45))),
        weight: 70,
      ),
    ]).animate(_iconCtrl);
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.15)
            .chain(CurveTween(curve: const _ElasticOutCurve(1.0, 0.45))),
        weight: 70,
      ),
    ]).animate(_iconCtrl);
    _iconRotation = Tween<double>(begin: -10 * math.pi / 180, end: 0)
        .chain(CurveTween(curve: const _ElasticOutCurve(1.1, 0.4)))
        .animate(_iconCtrl);

    _labelCtrl = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 260));
    _labelOpacity =
        CurvedAnimation(parent: _labelCtrl, curve: Curves.easeOut);
    _labelY = Tween<double>(begin: 6, end: 0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_labelCtrl);

    _hoverCtrl = AnimationController(
        vsync: vsync, duration: const Duration(milliseconds: 180));
    _hoverY = Tween<double>(begin: 0, end: -3)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_hoverCtrl);

    if (active) {
      _pillCtrl.value = 1.0;
      _iconCtrl.value = 1.0;
      _labelCtrl.value = 1.0;
      _isActive = true;
    }
  }

  bool _isActive = false;
  late final AnimationController _pillCtrl;
  late final Animation<double> _pillScale;
  late final Animation<double> _pillOpacity;
  late final AnimationController _iconCtrl;
  late final Animation<double> _iconY;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotation;
  late final AnimationController _labelCtrl;
  late final Animation<double> _labelOpacity;
  late final Animation<double> _labelY;
  late final AnimationController _hoverCtrl;
  late final Animation<double> _hoverY;

  bool get isActive => _isActive;
  Animation<double> get pillScale => _pillScale;
  Animation<double> get pillOpacity => _pillOpacity;
  Animation<double> get iconY => _iconY;
  Animation<double> get iconScale => _iconScale;
  Animation<double> get iconRotation => _iconRotation;
  Animation<double> get labelOpacity => _labelOpacity;
  Animation<double> get labelY => _labelY;
  Animation<double> get hoverY => _hoverY;

  void activate() {
    _isActive = true;
    _hoverCtrl.reverse();
    _pillCtrl.forward(from: 0.3);
    _iconCtrl.forward(from: 0);
    Future.delayed(
        const Duration(milliseconds: 100), () => _labelCtrl.forward(from: 0));
  }

  void deactivate() {
    _isActive = false;
    _pillCtrl.animateBack(0,
        duration: const Duration(milliseconds: 220), curve: Curves.easeIn);
    _iconCtrl.animateBack(0,
        duration: const Duration(milliseconds: 280),
        curve: const _BackOutCurve(1.4));
    _labelCtrl.animateTo(0,
        duration: const Duration(milliseconds: 160), curve: Curves.easeIn);
  }

  void hoverEnter() {
    if (_isActive) return;
    _hoverCtrl.forward();
  }

  void hoverExit() {
    if (_isActive) return;
    _hoverCtrl.reverse();
  }

  void dispose() {
    _pillCtrl.dispose();
    _iconCtrl.dispose();
    _labelCtrl.dispose();
    _hoverCtrl.dispose();
  }
}

// ─────────────────────────────────────────────
//  Single item widget
// ─────────────────────────────────────────────

class _NoonNavItem extends StatelessWidget {
  const _NoonNavItem({
    required this.item,
    required this.controller,
    required this.onTap,
    this.badge,
  });

  final _NavItem item;
  final _NoonItemController controller;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => controller.hoverEnter(),
      onExit: (_) => controller.hoverExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onTapDown: (_) => controller.hoverEnter(),
        onTapUp: (_) => controller.hoverExit(),
        onTapCancel: () => controller.hoverExit(),
        child: SizedBox(
          height: 56,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              controller.pillScale,
              controller.iconY,
              controller.iconScale,
              controller.iconRotation,
              controller.labelOpacity,
              controller.labelY,
              controller.hoverY,
            ]),
            builder: (context, _) {
              final isActive = controller.isActive;
              final yOffset =
                  isActive ? controller.iconY.value : controller.hoverY.value;

              Widget iconWidget = _NavIconPainter(
                icon: item.icon,
                active: isActive,
              );
              if (badge != null && badge! > 0) {
                iconWidget = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    iconWidget,
                    Positioned(
                      top: -2,
                      right: -4,
                      child: _Badge(count: badge!, active: isActive),
                    ),
                  ],
                );
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Pill
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Transform.scale(
                        scale: controller.pillScale.value,
                        child: Opacity(
                          opacity:
                              controller.pillOpacity.value.clamp(0.0, 1.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFCC00),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Icon + label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(0.0, yOffset)
                          ..rotateZ(
                              isActive ? controller.iconRotation.value : 0)
                          ..scale(
                              isActive ? controller.iconScale.value : 1.0),
                        child: SizedBox(
                            width: 24, height: 24, child: iconWidget),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 14,
                        child: Opacity(
                          opacity:
                              controller.labelOpacity.value.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, controller.labelY.value),
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.21,
                                color: Color(0xFF18181B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hover dot
                  Positioned(
                    bottom: 5,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: (!isActive && controller.hoverY.value < -0.5)
                          ? 0.6
                          : 0.0,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFCC00),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Badge
// ─────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.active});
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? const Color(0xFFFFCC00) : const Color(0xFF1F1F23),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Icon painter
// ─────────────────────────────────────────────

enum _NavIcon { home, search, cart, account }

class _NavIconPainter extends StatelessWidget {
  const _NavIconPainter({required this.icon, required this.active});
  final _NavIcon icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? const Color(0xFF18181B) : const Color(0xFF71717A);
    return CustomPaint(
        size: const Size(24, 24), painter: _IconPainter(icon: icon, color: color));
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter({required this.icon, required this.color});
  final _NavIcon icon;
  final Color color;

  Paint get _p => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    switch (icon) {
      case _NavIcon.home:
        _drawHome(canvas);
      case _NavIcon.search:
        _drawSearch(canvas);
      case _NavIcon.cart:
        _drawCart(canvas);
      case _NavIcon.account:
        _drawAccount(canvas);
    }
    canvas.restore();
  }

  void _drawHome(Canvas canvas) {
    final house = Path()
      ..moveTo(3, 10.5)
      ..lineTo(12, 3)
      ..lineTo(21, 10.5)
      ..lineTo(21, 20)
      ..arcToPoint(const Offset(20, 21),
          radius: const Radius.circular(1), clockwise: true)
      ..lineTo(5, 21)
      ..arcToPoint(const Offset(4, 20),
          radius: const Radius.circular(1), clockwise: true)
      ..close();
    canvas.drawPath(house, _p);
    canvas.drawPath(
        Path()
          ..moveTo(9, 21)
          ..lineTo(9, 13)
          ..lineTo(15, 13)
          ..lineTo(15, 21),
        _p);
  }

  void _drawSearch(Canvas canvas) {
    canvas.drawCircle(const Offset(11, 11), 7, _p);
    canvas.drawLine(const Offset(16.5, 16.5), const Offset(21, 21), _p);
  }

  void _drawCart(Canvas canvas) {
    canvas.drawPath(
        Path()
          ..moveTo(6, 2)
          ..lineTo(3, 6)
          ..lineTo(3, 20)
          ..arcToPoint(const Offset(5, 22),
              radius: const Radius.circular(2), clockwise: false)
          ..lineTo(19, 22)
          ..arcToPoint(const Offset(21, 20),
              radius: const Radius.circular(2), clockwise: false)
          ..lineTo(21, 6)
          ..lineTo(18, 2)
          ..close(),
        _p);
    canvas.drawLine(const Offset(3, 6), const Offset(21, 6), _p);
    canvas.drawPath(
        Path()
          ..moveTo(16, 10)
          ..arcToPoint(const Offset(8, 10),
              radius: const Radius.circular(4), clockwise: false),
        _p);
  }

  void _drawAccount(Canvas canvas) {
    canvas.drawCircle(const Offset(12, 8), 4, _p);
    canvas.drawPath(
        Path()
          ..moveTo(4, 21)
          ..cubicTo(4, 17, 7.6, 14, 12, 14)
          ..cubicTo(16.4, 14, 20, 17, 20, 21),
        _p);
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color;
}

// ─────────────────────────────────────────────
//  Custom spring curves
// ─────────────────────────────────────────────

/// GSAP back.out(overshoot): 1 + (s+1)(t−1)³ + s(t−1)²
class _BackOutCurve extends Curve {
  const _BackOutCurve(this.overshoot);
  final double overshoot;

  @override
  double transformInternal(double t) {
    final s = overshoot;
    final u = t - 1;
    return 1 + (s + 1) * u * u * u + s * u * u;
  }
}

/// GSAP elastic.out(amplitude, period)
class _ElasticOutCurve extends Curve {
  const _ElasticOutCurve(this.amplitude, this.period);
  final double amplitude;
  final double period;

  @override
  double transformInternal(double t) {
    if (t == 0 || t == 1) return t;
    final a = amplitude < 1 ? 1.0 : amplitude;
    final s = math.asin(1 / a) * (period / (2 * math.pi));
    return a *
            math.pow(2, -10 * t).toDouble() *
            math.sin((t - s) * (2 * math.pi) / period) +
        1;
  }
}

// ─────────────────────────────────────────────
//  Data
// ─────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.label, required this.icon});
  final String label;
  final _NavIcon icon;
}
