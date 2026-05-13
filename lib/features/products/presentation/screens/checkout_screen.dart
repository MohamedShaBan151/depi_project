import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../../cubits/shopping_cubit.dart';
import '../../../auth/data/models/user_model.dart' show FirestoreAddress;
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/address_service.dart';
import '../../data/models/order_model.dart';
import '../../data/models/coupon_model.dart';
import '../../data/payment_gateway.dart';
import '../cubit/order_cubit.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  String? _selectedAddress;
  String _selectedDelivery = 'delivery';
  String _selectedPayment = 'cod';
  bool _isProcessing = false;

  List<FirestoreAddress> _addresses = [];
  final _couponController = TextEditingController();
  Coupon? _appliedCoupon;
  double _discount = 0;

  static const _deliveryFees = {'delivery': 0.0, 'pickup': 0.0, 'express': 15.0};
  double get _deliveryFee => _deliveryFees[_selectedDelivery] ?? 0.0;

  @override
  void initState() {
    super.initState();
    _addresses = AddressService.loadAddresses();
    if (_addresses.isNotEmpty) {
      final defaultAddr = _addresses.where((a) => a.isDefault).firstOrNull ?? _addresses.first;
      _selectedAddress = defaultAddr.id;
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    final coupon = CouponService.validateCoupon(code);
    if (coupon != null) {
      setState(() {
        _appliedCoupon = coupon;
        _discount = coupon.getDiscountAmount(context.read<ShoppingCubit>().state.cartTotal);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coupon applied! You save SAR ${_discount.toStringAsFixed(2)}'),
            backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired coupon'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text('الشحن والدفع'),
        centerTitle: true,
      ),
      body: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) return _buildEmptyCart();
          return Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () => _handleContinue(state),
            onStepCancel: _handleCancel,
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  _isProcessing
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkGreen,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_currentStep == 2 ? 'تأكيد الطلب' : 'Continue'),
                        ),
                ]),
              );
            },
            steps: [
              Step(title: const Text('Address'), content: _buildAddressStep(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed),
              Step(title: const Text('Delivery'), content: _buildDeliveryStep(state),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed),
              Step(title: const Text('Payment'), content: _buildPaymentStep(state),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shopping_cart_outlined, size: 80,
            color: AppColors.darkGreen.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        const Text('Your cart is empty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen, foregroundColor: Colors.white,
          ),
          child: const Text('Continue Shopping'),
        ),
      ]),
    );
  }

  Widget _buildAddressStep() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اختر عنوان التوصيل',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      ...(_addresses.isEmpty
          ? [const Text('No addresses saved. Please add an address.')]
          : _addresses.map(_buildAddressCard)),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () => context.push('/addresses'),
        icon: const Icon(Icons.add),
        label: const Text('إدارة العناوين'),
        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
      ),
    ]);
  }

  Widget _buildAddressCard(FirestoreAddress address) {
    final isSelected = _selectedAddress == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          _RadioCircle(selected: isSelected),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(address.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(address.address,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('${address.city}, ${address.district}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildDeliveryStep(ShoppingState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اختر طريقة التوصيل',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      _buildDeliveryOption('توصيل منزلي', 'Free', '2-4 أيام', 'delivery'),
      const SizedBox(height: 12),
      _buildDeliveryOption('استلام من المتجر', 'Free', 'غداً', 'pickup'),
      const SizedBox(height: 12),
      _buildDeliveryOption('توصيل في نفس اليوم', 'ر.س15', 'اليوم', 'express'),
      const SizedBox(height: 24),
      _buildOrderSummaryCard(state),
    ]);
  }

  Widget _buildDeliveryOption(String title, String price, String time, String value) {
    final isSelected = _selectedDelivery == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedDelivery = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          _RadioCircle(selected: isSelected),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          Text(price, style: TextStyle(
              fontWeight: FontWeight.w700,
              color: price == 'Free' ? AppColors.success : AppColors.ink)),
        ]),
      ),
    );
  }

  Widget _buildOrderSummaryCard(ShoppingState state) {
    final total = state.cartTotal + _deliveryFee - _discount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGold.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.local_shipping, size: 20, color: AppColors.darkGreen),
          SizedBox(width: 8),
          Text('ملخص الطلب', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        _summaryRow('المجموع الفرعي', 'ر.س${state.cartTotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        _summaryRow('التوصيل',
            _deliveryFee == 0 ? 'Free' : 'ر.س${_deliveryFee.toStringAsFixed(0)}',
            valueColor: _deliveryFee == 0 ? AppColors.success : AppColors.ink),
        if (_discount > 0) ...[
          const SizedBox(height: 8),
          _summaryRow('الخصم', '-ر.س${_discount.toStringAsFixed(2)}',
              valueColor: AppColors.error),
        ],
        const Divider(height: 24),
        _summaryRow('الإجمالي', 'ر.س${total.toStringAsFixed(2)}',
            bold: true, valueColor: AppColors.darkGreen),
      ]),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.normal, color: valueColor)),
    ]);
  }

  Widget _buildPaymentStep(ShoppingState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('اختر طريقة الدفع',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      _buildPaymentOption('الدفع عند الاستلام', 'cod', Icons.money),
      const SizedBox(height: 12),
      _buildPaymentOption('بطاقة الائتمان', 'card', Icons.credit_card),
      const SizedBox(height: 12),
      _buildPaymentOption('Apple Pay', 'apple', Icons.apple),
      const SizedBox(height: 24),
      if (_selectedPayment == 'card') _buildCardForm(),
      const SizedBox(height: 16),
      _buildCouponSection(),
      const SizedBox(height: 16),
      _buildOrderSummaryCard(state),
    ]);
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Coupon Code', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _applyCoupon,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Apply'),
          ),
        ]),
        if (_appliedCoupon != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 16),
            const SizedBox(width: 4),
            Text('${_appliedCoupon!.code} applied',
                style: const TextStyle(color: AppColors.success, fontSize: 12)),
          ]),
        ],
      ]),
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          _RadioCircle(selected: isSelected),
          const SizedBox(width: 12),
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'رقم البطاقة', hintText: '**** **** **** ****',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'تاريخ الانتهاء', hintText: 'MM/YY',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.datetime,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'CVV', hintText: '***',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ),
        ]),
      ]),
    );
  }

  void _handleContinue(ShoppingState state) {
    if (_currentStep == 0) {
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار عنوان التوصيل'), backgroundColor: Colors.red),
        );
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _placeOrder(state);
    }
  }

  void _handleCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _placeOrder(ShoppingState state) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final paymentService = PaymentService(
        provider: _selectedPayment == 'cod'
            ? PaymentProvider.cod
            : PaymentProvider.paymob,
      );
      final result = await paymentService.processPayment(
        amount: state.cartTotal + _deliveryFee - _discount,
        currency: 'SAR',
        paymentMethod: {'type': _selectedPayment, 'addressId': _selectedAddress},
      );

      if (!result.success) throw Exception(result.errorMessage ?? 'Payment failed');

      final selectedAddr = _addresses.firstWhere(
        (a) => a.id == _selectedAddress,
        orElse: () => _addresses.first,
      );

      String userId = 'guest';
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated && authState.user != null) {
        userId = authState.user!.uid;
      }

      final order = FirestoreOrder(
        id: result.transactionId ?? 'ORD${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        items: state.cartItems
            .map((ci) => OrderItem(
                  productId: ci.product.id,
                  productName: ci.product.name,
                  imageUrl: ci.product.imageUrl,
                  price: ci.product.price,
                  quantity: ci.quantity,
                ))
            .toList(),
        subtotal: state.cartTotal,
        deliveryFee: _deliveryFee,
        discount: _discount,
        total: state.cartTotal + _deliveryFee - _discount,
        status: OrderStatus.confirmed,
        shippingAddress: selectedAddr,
        paymentInfo: PaymentInfo(
          method: _selectedPayment,
          transactionId: result.transactionId,
          status: PaymentStatus.completed,
          paidAt: DateTime.now(),
        ),
        createdAt: DateTime.now(),
      );

      if (mounted) {
        context.read<OrderCubit>().createOrder(order);
        context.read<ShoppingCubit>().clearCart();
        context.go(
          '/order-confirmation'
          '?orderId=${Uri.encodeComponent(order.id)}'
          '&total=${order.total}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الدفع: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _RadioCircle extends StatelessWidget {
  final bool selected;
  const _RadioCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.darkGreen : AppColors.divider,
          width: 2,
        ),
        color: selected ? AppColors.darkGreen : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
