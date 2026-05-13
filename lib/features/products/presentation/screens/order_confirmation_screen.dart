import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../data/models/order_model.dart';
import '../cubit/order_cubit.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final double total;
  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.total,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showDetails = true);
    });

    context.read<OrderCubit>().watchOrder(widget.orderId);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text('Order Confirmed'),
        centerTitle: true,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          FirestoreOrder? order;
          if (state is OrderTrackingUpdated) {
            order = state.order;
          }

          return SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 56, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed Successfully!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              const SizedBox(height: 8),
              Text('Order #${widget.orderId}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Total: ر.س${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkGreen)),
              const SizedBox(height: 32),
              if (order != null) _buildTrackingTimeline(order),
              const SizedBox(height: 16),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildDetailsCard(),
                crossFadeState: _showDetails
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 500),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/orders'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Track My Order',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: const Text('Continue Shopping',
                        style: TextStyle(fontSize: 16)),
                  ),
                ]),
              ),
              const SizedBox(height: 40),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildTrackingTimeline(FirestoreOrder order) {
    final statuses = [
      OrderStatus.confirmed,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.outForDelivery,
      OrderStatus.delivered,
    ];

    final currentIdx = statuses.indexOf(order.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Order Progress',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 16),
        ...List.generate(statuses.length, (i) {
          final status = statuses[i];
          final isCompleted = i <= currentIdx;
          final isCurrent = i == currentIdx;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.darkGreen : Colors.grey.shade300,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle_outlined,
                    size: 14, color: Colors.white,
                  ),
                ),
                if (i < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: i < currentIdx ? AppColors.darkGreen : Colors.grey.shade300,
                  ),
              ]),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                    color: isCompleted ? AppColors.darkGreen : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('What happens next?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        _stepRow(Icons.check_circle, 'Order confirmed by seller'),
        _stepRow(Icons.inventory_2, 'Items are being packed'),
        _stepRow(Icons.local_shipping, 'Order shipped to your address'),
        _stepRow(Icons.delivery_dining, 'Out for delivery'),
        _stepRow(Icons.check_circle_outline, 'Delivered to your doorstep'),
      ]),
    );
  }

  Widget _stepRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.darkGreen),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }
}
