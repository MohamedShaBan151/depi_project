import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<FirestoreOrder> orders;
  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderCubit extends Cubit<OrderState> {
  List<FirestoreOrder> _orders = [];

  OrderCubit() : super(OrderInitial());

  void createOrder(FirestoreOrder order) {
    final orders = List<FirestoreOrder>.from(_orders);
    orders.add(order);
    _orders = orders;
    emit(OrderLoaded(orders));
  }

  void loadOrders() {
    emit(OrderLoading());
    emit(OrderLoaded(_orders));
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final orders = _orders.map((order) {
      if (order.id == orderId) {
        return FirestoreOrder(
          id: order.id,
          userId: order.userId,
          items: order.items,
          subtotal: order.subtotal,
          deliveryFee: order.deliveryFee,
          discount: order.discount,
          total: order.total,
          status: status,
          shippingAddress: order.shippingAddress,
          paymentInfo: order.paymentInfo,
          createdAt: order.createdAt,
        );
      }
      return order;
    }).toList();
    _orders = orders;
    emit(OrderLoaded(orders));
  }
}