import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/models.dart' show CartItem, Product;
import '../data/data_sources/cart_persistence_service.dart';
import '../features/products/domain/entities/product.dart' as domain;

class ShoppingState extends Equatable {
  final List<CartItem> cartItems;
  final List<Product> wishlist;

  const ShoppingState({
    this.cartItems = const [],
    this.wishlist = const [],
  });

  int get cartCount => cartItems.fold(0, (sum, i) => sum + i.quantity);

  double get cartTotal => cartItems.fold(0, (sum, i) => sum + i.subtotal);

  bool isInCart(String productId) =>
      cartItems.any((i) => i.product.id == productId);

  bool isWishlisted(String productId) => wishlist.any((p) => p.id == productId);

  static const double freeShippingThreshold = 200.0;

  double get freeShippingProgress =>
      (cartTotal / freeShippingThreshold).clamp(0.0, 1.0);

  bool get qualifiesForFreeShipping => cartTotal >= freeShippingThreshold;

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

class ShoppingCubit extends Cubit<ShoppingState> {
  final CartPersistenceService? _persistence;

  ShoppingCubit([this._persistence]) : super(const ShoppingState());

  void loadPersistedCart() {
    if (_persistence == null) return;
    final saved = _persistence?.loadCart();
    final wishlistSaved = _persistence?.loadWishlist();
    if ((saved != null && saved.isNotEmpty) ||
        (wishlistSaved != null && wishlistSaved.isNotEmpty)) {
      emit(state.copyWith(
        cartItems: saved ?? [],
        wishlist: wishlistSaved ?? [],
      ));
    }
  }

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

  void addToCartFromDomain(domain.Product product) {
    addToCart(Product(
      id: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      originalPrice: product.originalPrice,
      rating: product.rating,
      reviewCount: product.reviewCount,
      stock: product.stock,
      imageUrl: product.imageUrl,
      isFeatured: product.isFeatured,
    ));
  }

  void toggleWishlistFromDomain(domain.Product product) {
    toggleWishlist(Product(
      id: product.id,
      name: product.name,
      category: product.category,
      price: product.price,
      originalPrice: product.originalPrice,
      rating: product.rating,
      reviewCount: product.reviewCount,
      stock: product.stock,
      imageUrl: product.imageUrl,
      isFeatured: product.isFeatured,
    ));
  }

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

  void deleteFromCart(String productId) {
    final items =
        state.cartItems.where((i) => i.product.id != productId).toList();
    _emitAndPersist(state.copyWith(cartItems: items));
  }

  void clearCart() => _emitAndPersist(state.copyWith(cartItems: []));

  void toggleWishlist(Product product) {
    final list = List<Product>.from(state.wishlist);
    final exists = list.any((p) => p.id == product.id);
    if (exists) {
      list.removeWhere((p) => p.id == product.id);
    } else {
      list.add(product);
    }
    emit(state.copyWith(wishlist: list));
    _persistence?.saveWishlist(list);
  }

  void _emitAndPersist(ShoppingState newState) {
    emit(newState);
    _persistence?.saveCart(newState.cartItems);
  }
}
