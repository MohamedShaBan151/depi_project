// ─────────────────────────────────────────────────────────────────────────────
// shopping_cubit.dart  –  Cart + Wishlist  (with cart persistence)
//
// Cart mutations are immediately persisted to SharedPreferences via
// CartPersistenceService so the basket survives app restarts.
//
// Usage in main.dart:
//   final prefs = await SharedPreferences.getInstance();
//   BlocProvider(
//     create: (_) => ShoppingCubit(CartPersistenceService(prefs))
//                       ..loadPersistedCart(),
//   )
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/models.dart' show CartItem, Product;
import '../data/data_sources/cart_persistence_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ShoppingState extends Equatable {
  final List<CartItem> cartItems;
  final List<Product> wishlist;

  const ShoppingState({
    this.cartItems = const [],
    this.wishlist = const [],
  });

  // ── Derived getters ────────────────────────────────────────────────────────

  int get cartCount => cartItems.fold(0, (sum, i) => sum + i.quantity);

  double get cartTotal => cartItems.fold(0, (sum, i) => sum + i.subtotal);

  bool isInCart(String productId) =>
      cartItems.any((i) => i.product.id == productId);

  bool isWishlisted(String productId) => wishlist.any((p) => p.id == productId);

  /// Free-shipping threshold (SAR).  Drives the progress bar.
  static const double freeShippingThreshold = 200.0;

  double get freeShippingProgress =>
      (cartTotal / freeShippingThreshold).clamp(0.0, 1.0);

  bool get qualifiesForFreeShipping => cartTotal >= freeShippingThreshold;

  // ── copyWith ───────────────────────────────────────────────────────────────

  ShoppingState copyWith({
    List<CartItem>? cartItems,
    List<Product>? wishlist,
  }) =>
      ShoppingState(
        cartItems: cartItems ?? this.cartItems,
        wishlist: wishlist ?? this.wishlist,
      );

  @override
  List<Object?> get props => [cartItems, wishlist];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class ShoppingCubit extends Cubit<ShoppingState> {
  /// Pass [null] in tests to skip persistence entirely.
  final CartPersistenceService? _persistence;

  ShoppingCubit([this._persistence]) : super(const ShoppingState());

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Rehydrates the cart from SharedPreferences.
  /// Call once after the cubit is created (done in main.dart).
  void loadPersistedCart(){
    if (_persistence == null) return;
    final saved = _persistence?.loadCart();
    if (saved!.isNotEmpty) {
      emit(state.copyWith(cartItems: saved));
    }
  }

  // ── Cart ───────────────────────────────────────────────────────────────────

  /// Adds product to cart; increments quantity if already present.
  void addToCart(Product product) {
    final items = List<CartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == product.id);

    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: product));
    }
    _emitAndPersist(state.copyWith(cartItems: items));
  }

  /// Decrements quantity; removes the item when quantity reaches 0.
  void removeFromCart(String productId) {
    final items = List<CartItem>.from(state.cartItems);
    final idx = items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;

    if (items[idx].quantity > 1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
    } else {
      items.removeAt(idx);
    }
    _emitAndPersist(state.copyWith(cartItems: items));
  }

  /// Removes all units of a product in one call.
  void deleteFromCart(String productId) {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    _emitAndPersist(state.copyWith(cartItems: items));
  }

  void clearCart() => _emitAndPersist(state.copyWith(cartItems: []));

  // ── Wishlist ───────────────────────────────────────────────────────────────

  void toggleWishlist(Product product) {
    final list = List<Product>.from(state.wishlist);
    final exists = list.any((p) => p.id == product.id);

    if (exists) {
      list.removeWhere((p) => p.id == product.id);
    } else {
      list.add(product);
    }
    emit(state.copyWith(wishlist: list));
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _emitAndPersist(ShoppingState newState) {
    emit(newState);
    _persistence?.saveCart(newState.cartItems); // fire-and-forget is fine
  }
}
