// lib/features/products/presentation/cubit/cart_cubit.dart
// ─────────────────────────────────────────────────────────────────────────────
// Manages the shopping cart.
// - When user is signed in  → streams /users/{uid}/cart in real-time.
// - When user is signed out → falls back to local in-memory list.
// On sign-in the guest items are merged into Firestore.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../data/models/cart_item_model.dart';
import '../../../../data/repositories/cart_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

abstract class CartState extends Equatable {
  const CartState();
}

class CartInitial extends CartState {
  @override
  List<Object?> get props => [];
}

class CartLoading extends CartState {
  @override
  List<Object?> get props => [];
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  const CartLoaded(this.items);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalQty =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repo) : super(CartInitial());

  final CartRepository _repo;

  StreamSubscription<List<CartItemModel>>? _sub;
  String? _userId;

  /// Call when user logs in. Merges any guest items and starts the stream.
  Future<void> onUserSignedIn(String userId,
      {List<CartItemModel> guestItems = const []}) async {
    _userId = userId;
    if (guestItems.isNotEmpty) {
      await _repo.mergeGuestCart(userId, guestItems);
    }
    _startStream(userId);
  }

  /// Call when user signs out — clears the stream and emits empty cart.
  void onUserSignedOut() {
    _sub?.cancel();
    _userId = null;
    emit(const CartLoaded([]));
  }

  void _startStream(String userId) {
    emit(CartLoading());
    _sub?.cancel();
    _sub = _repo.watchCart(userId).listen(
      (items) => emit(CartLoaded(items)),
      onError: (e) => emit(CartError(e.toString())),
    );
  }

  Future<void> addItem(CartItemModel item) async {
    if (_userId == null) {
      // Guest cart — manipulate local state directly.
      final current = state is CartLoaded
          ? (state as CartLoaded).items
          : <CartItemModel>[];
      final updated = List<CartItemModel>.from(current)..add(item);
      emit(CartLoaded(updated));
      return;
    }
    try {
      await _repo.addItem(_userId!, item);
      // Stream will update state automatically.
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (_userId == null) return;
    try {
      await _repo.updateQuantity(_userId!, itemId, quantity);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> removeItem(String itemId) async {
    if (_userId == null) {
      if (state is CartLoaded) {
        final updated = (state as CartLoaded)
            .items
            .where((i) => i.id != itemId)
            .toList();
        emit(CartLoaded(updated));
      }
      return;
    }
    try {
      await _repo.removeItem(_userId!, itemId);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> clearCart() async {
    if (_userId == null) {
      emit(const CartLoaded([]));
      return;
    }
    try {
      await _repo.clearCart(_userId!);
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
