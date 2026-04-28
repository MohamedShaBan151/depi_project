// ─────────────────────────────────────────────────────────────────────────────
// shopping_cubit.dart  –  Single Cubit that owns Cart + Wishlist
//
// Keeping both concerns in one class avoids BlocProvider duplication and
// lets the cart badge & wishlist icon react to the same state snapshot.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/models.dart' show CartItem, Product;

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
  ShoppingCubit() : super(const ShoppingState());

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
    emit(state.copyWith(cartItems: items));
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
    emit(state.copyWith(cartItems: items));
  }

  /// Removes all units of a product in one call.
  void deleteFromCart(String productId) {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    emit(state.copyWith(cartItems: items));
  }

  void clearCart() => emit(state.copyWith(cartItems: []));

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
}
