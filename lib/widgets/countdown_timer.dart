import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/saudi_theme.dart';

/// Counts down from a fixed end time. Refreshes every second.
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  // Demo: count down 6 hours from widget creation
  late DateTime _endTime;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _endTime = DateTime.now().add(const Duration(hours: 6));
    _remaining = _endTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = _endTime.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));

    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
        const SizedBox(width: 6),
        const Text('Deal ends in ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        _Segment(h),
        const _Sep(),
        _Segment(m),
        const _Sep(),
        _Segment(s),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String value;
  const _Segment(this.value);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.darkGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );
}

class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.symmetric(horizontal: 3), child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)));
}
