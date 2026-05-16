import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/order_firestore_service.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override List<Object?> get props => [];
}

class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}
class OrderLoaded extends OrderState {
  final List<FirestoreOrder> orders;
  const OrderLoaded(this.orders);
  @override List<Object?> get props => [orders];
}
class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override List<Object?> get props => [message];
}
class OrderTrackingUpdated extends OrderState {
  final FirestoreOrder order;
  const OrderTrackingUpdated(this.order);
  @override List<Object?> get props => [order];
}

class OrderCubit extends Cubit<OrderState> {
  final OrderFirestoreService _firestoreService = OrderFirestoreService();
  List<FirestoreOrder> _orders = [];
  StreamSubscription<dynamic>? _subscription;

  OrderCubit(Object object) : super(OrderInitial());

  void createOrder(FirestoreOrder order) {
    final orders = List<FirestoreOrder>.from(_orders);
    orders.insert(0, order);
    _orders = orders;
    emit(OrderLoaded(orders));
    _firestoreService.saveOrder(order);
  }

  void loadOrders({String? userId}) {
    emit(OrderLoading());
    if (userId != null) {
      _subscription?.cancel();
      _subscription = _firestoreService.watchOrders(userId).listen(
        (orders) {
          _orders = orders;
          emit(OrderLoaded(orders));
        },
        onError: (e) => emit(OrderError(e.toString())),
      );
    } else {
      emit(OrderLoaded(_orders));
    }
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
    _firestoreService.updateOrderStatus(orderId, status);
  }

  void watchOrder(String orderId) {
    _subscription?.cancel();
    _subscription = _firestoreService.watchOrder(orderId).listen(
      (order) {
        if (order != null) {
          final idx = _orders.indexWhere((o) => o.id == order.id);
          if (idx != -1) {
            _orders[idx] = order;
          } else {
            _orders.insert(0, order);
          }
          emit(OrderTrackingUpdated(order));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
