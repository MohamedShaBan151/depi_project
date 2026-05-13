import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/saudi_theme.dart';
import '../../data/models/order_model.dart';
import '../cubit/order_cubit.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _statusFilters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'processing', 'label': 'Processing'},
    {'key': 'shipped', 'label': 'Shipped'},
    {'key': 'delivered', 'label': 'Delivered'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    context.read<OrderCubit>().loadOrders(
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text('طلباتي · Orders'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: _statusFilters.map((filter) {
            return Tab(text: filter['label'] as String);
          }).toList(),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderLoaded || state is OrderTrackingUpdated) {
            final List<FirestoreOrder> orders;
            if (state is OrderLoaded) {
              orders = state.orders;
            } else if (state is OrderTrackingUpdated) {
              orders = [state.order];
            } else {
              orders = [];
            }
            if (orders.isEmpty) return _buildEmptyState();
            return TabBarView(
              controller: _tabController,
              children: _statusFilters.map((filter) {
                final key = filter['key'] as String;
                final filteredOrders = key == 'all'
                    ? orders
                    : orders.where((order) => order.status.name == key).toList();
                return _buildOrderList(filteredOrders);
              }).toList(),
            );
          }
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shopping_bag_outlined, size: 80,
            color: AppColors.darkGreen.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        const Text('No orders yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Start shopping to see your orders here',
            style: TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildOrderList(List<FirestoreOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 48,
              color: AppColors.darkGreen.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          const Text('No orders in this category',
              style: TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildOrderCard(FirestoreOrder order) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGreen.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(dateFormat.format(order.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
            _buildStatusChip(order.status),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Products', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 8),
            ...order.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, size: 20, color: AppColors.darkGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.productName, style: const TextStyle(fontSize: 13),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Qty: ${item.quantity}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ]),
                  ),
                  Text('ر.س${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              );
            }),
            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${order.items.length - 3} more items',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('ر.س${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.darkGreen)),
            ]),
            if (order.discount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Discount: -ر.س${order.discount.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.success, fontSize: 12)),
              ),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showTrackingDialog(order),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                child: const Text('Track'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                child: const Text('Buy Again'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showTrackingDialog(FirestoreOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.local_shipping, color: AppColors.darkGreen),
          const SizedBox(width: 8),
          const Text('Order Tracking'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...OrderStatus.values.map((status) {
              final isCompleted = status.index <= order.status.index;
              final isCurrent = status == order.status;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
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
                  const SizedBox(width: 12),
                  Text(status.label,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                        color: isCompleted ? AppColors.darkGreen : Colors.grey,
                      )),
                ]),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    final colors = {
      OrderStatus.pending: AppColors.gold,
      OrderStatus.confirmed: AppColors.teal,
      OrderStatus.processing: AppColors.teal,
      OrderStatus.shipped: AppColors.slate,
      OrderStatus.outForDelivery: AppColors.slate,
      OrderStatus.delivered: AppColors.success,
      OrderStatus.cancelled: AppColors.error,
      OrderStatus.refunded: AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors[status]?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[status] ?? AppColors.divider),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_getStatusIcon(status), size: 14, color: colors[status]),
        const SizedBox(width: 4),
        Text(status.labelAr,
            style: TextStyle(color: colors[status], fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Icons.hourglass_empty;
      case OrderStatus.confirmed: return Icons.check_circle;
      case OrderStatus.processing: return Icons.inventory_2;
      case OrderStatus.shipped: return Icons.local_shipping;
      case OrderStatus.outForDelivery: return Icons.delivery_dining;
      case OrderStatus.delivered: return Icons.check_circle;
      case OrderStatus.cancelled: return Icons.cancel;
      case OrderStatus.refunded: return Icons.replay;
    }
  }
}
