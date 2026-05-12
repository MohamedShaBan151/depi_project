import 'package:flutter/material.dart';
import '../core/theme/saudi_theme.dart';

/// A horizontal strip showing shipping / return / payment perks.
class PromoStrip extends StatelessWidget {
  const PromoStrip({super.key});

  static const _perks = [
    ('Free Shipping', Icons.local_shipping_outlined),
    ('Easy Returns', Icons.assignment_return_outlined),
    ('Secure Pay', Icons.lock_outline),
    ('24/7 Support', Icons.headset_mic_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _perks.map((p) => _PerkItem(label: p.$1, icon: p.$2)).toList(),
      ),
    );
  }
}

class _PerkItem extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PerkItem({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.darkGreen),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.darkGreen)),
        ],
      );
}
