// ─────────────────────────────────────────────────────────────────────────────
// shopping_cubit_test.dart
//
// Unit tests for ShoppingCubit covering:
//   • In-memory cart operations (add / remove / delete / clear)
//   • Quantity arithmetic
//   • Model field round-trip integrity
//   • Wishlist toggle
//   • Derived state: cartTotal, freeShippingProgress, qualifiesForFreeShipping
//   • Cart persistence: loadPersistedCart, save on mutation, clear on clearCart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:noon_clone/cubits/shopping_cubit.dart';
import 'package:noon_clone/data/models/models.dart';
import 'package:noon_clone/data/data_sources/cart_persistence_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _cheap = Product(
  id: 'c1', name: 'Cheap Item', category: 'Grocery', price: 50, stock: 100,
);

const _expensive = Product(
  id: 'e1',
  name: 'Expensive Item',
  category: 'Electronics',
  price: 300,
  originalPrice: 350,
  stock: 10,
  rating: 4.5,
  reviewCount: 200,
  isFeatured: true,
);

ShoppingCubit _noStorage() => ShoppingCubit();

Future<(ShoppingCubit, CartPersistenceService)> _withStorage() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final svc = CartPersistenceService(prefs);
  final cubit = ShoppingCubit(svc);
  return (cubit, svc);
}

void main() {
  // ── 1. Basic cart operations ───────────────────────────────────────────────
  group('ShoppingCubit – cart operations', () {
    late ShoppingCubit cubit;
    setUp(() => cubit = _noStorage());
    tearDown(() => cubit.close());

    test('initial state is empty', () {
      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.cartCount, 0);
      expect(cubit.state.cartTotal, 0.0);
    });

    test('addToCart adds new item with quantity 1', () {
      cubit.addToCart(_cheap);
      expect(cubit.state.cartCount, 1);
      expect(cubit.state.cartItems.length, 1);
    });

    test('addToCart twice increments quantity, not item count', () {
      cubit.addToCart(_cheap);
      cubit.addToCart(_cheap);
      expect(cubit.state.cartItems.length, 1);
      expect(cubit.state.cartCount, 2);
    });

    test('removeFromCart decrements quantity', () {
      cubit.addToCart(_cheap);
      cubit.addToCart(_cheap);
      cubit.removeFromCart(_cheap.id);
      expect(cubit.state.cartCount, 1);
    });

    test('removeFromCart removes item when quantity reaches 0', () {
      cubit.addToCart(_cheap);
      cubit.removeFromCart(_cheap.id);
      expect(cubit.state.cartItems, isEmpty);
    });

    test('removeFromCart is a no-op for unknown product', () {
      cubit.addToCart(_cheap);
      cubit.removeFromCart('not-a-real-id');
      expect(cubit.state.cartCount, 1);
    });

    test('deleteFromCart removes all units at once', () {
      cubit.addToCart(_cheap);
      cubit.addToCart(_cheap);
      cubit.addToCart(_cheap);
      cubit.deleteFromCart(_cheap.id);
      expect(cubit.state.cartItems, isEmpty);
    });

    test('clearCart removes all items', () {
      cubit.addToCart(_cheap);
      cubit.addToCart(_expensive);
      cubit.clearCart();
      expect(cubit.state.cartItems, isEmpty);
      expect(cubit.state.cartCount, 0);
    });

    test('multiple distinct products are tracked independently', () {
      cubit.addToCart(_cheap);
      cubit.addToCart(_expensive);
      expect(cubit.state.cartItems.length, 2);
      expect(cubit.state.cartCount, 2);
    });
  });

  // ── 2. Derived state ───────────────────────────────────────────────────────
  group('ShoppingCubit – derived state', () {
    late ShoppingCubit cubit;
    setUp(() => cubit = _noStorage());
    tearDown(() => cubit.close());

    test('cartTotal sums all item subtotals', () {
      cubit.addToCart(_cheap);     // 50
      cubit.addToCart(_cheap);     // 50 × 2 = 100
      cubit.addToCart(_expensive); // 300  → total = 400
      expect(cubit.state.cartTotal, 400.0);
    });

    test('isInCart returns true after add', () {
      cubit.addToCart(_cheap);
      expect(cubit.state.isInCart(_cheap.id), isTrue);
    });

    test('isInCart returns false for unknown product', () {
      expect(cubit.state.isInCart('unknown'), isFalse);
    });

    test('freeShippingProgress is clamped to [0, 1]', () {
      // 0 items → 0
      expect(cubit.state.freeShippingProgress, 0.0);
      // Add > threshold
      cubit.addToCart(_expensive); // 300 ≥ 200 threshold
      expect(cubit.state.freeShippingProgress, 1.0);
    });

    test('qualifiesForFreeShipping is true when total ≥ threshold', () {
      cubit.addToCart(_expensive); // 300 ≥ 200
      expect(cubit.state.qualifiesForFreeShipping, isTrue);
    });

    test('qualifiesForFreeShipping is false when total < threshold', () {
      cubit.addToCart(_cheap); // 50 < 200
      expect(cubit.state.qualifiesForFreeShipping, isFalse);
    });
  });

  // ── 3. Model round-trip integrity ─────────────────────────────────────────
  group('ShoppingCubit – model field integrity', () {
    test('all product fields survive addToCart round-trip', () {
      final cubit = _noStorage();
      cubit.addToCart(_expensive);
      final item = cubit.state.cartItems.first;
      expect(item.product.id, _expensive.id);
      expect(item.product.originalPrice, 350.0);
      expect(item.product.rating, 4.5);
      expect(item.product.reviewCount, 200);
      expect(item.product.isFeatured, isTrue);
      cubit.close();
    });
  });

  // ── 4. Wishlist ────────────────────────────────────────────────────────────
  group('ShoppingCubit – wishlist', () {
    late ShoppingCubit cubit;
    setUp(() => cubit = _noStorage());
    tearDown(() => cubit.close());

    test('toggleWishlist adds product when not present', () {
      cubit.toggleWishlist(_cheap);
      expect(cubit.state.isWishlisted(_cheap.id), isTrue);
    });

    test('toggleWishlist removes product when already present', () {
      cubit.toggleWishlist(_cheap);
      cubit.toggleWishlist(_cheap);
      expect(cubit.state.isWishlisted(_cheap.id), isFalse);
    });

    test('wishlist is independent of cart state', () {
      cubit.addToCart(_cheap);
      cubit.toggleWishlist(_expensive);
      expect(cubit.state.cartCount, 1);
      expect(cubit.state.wishlist.length, 1);
    });
  });

  // ── 5. Cart persistence ────────────────────────────────────────────────────
  group('ShoppingCubit – persistence', () {
    test('loadPersistedCart is a no-op when there is no saved data', () async {
      final (cubit, _) = await _withStorage();
      cubit.loadPersistedCart();
      expect(cubit.state.cartItems, isEmpty);
      cubit.close();
    });

    test('addToCart persists to SharedPreferences', () async {
      final (cubit, svc) = await _withStorage();
      cubit.addToCart(_cheap);

      // Allow the fire-and-forget persist to complete.
      await Future.delayed(Duration.zero);

      final saved = svc.loadCart();
      expect(saved.length, 1);
      expect(saved.first.product.id, _cheap.id);
      cubit.close();
    });

    test('loadPersistedCart restores items from SharedPreferences', () async {
      final (cubit1, svc) = await _withStorage();
      cubit1.addToCart(_cheap);
      cubit1.addToCart(_cheap); // qty = 2
      await Future.delayed(Duration.zero);
      cubit1.close();

      // Simulate app restart with same prefs
      final cubit2 = ShoppingCubit(svc)..loadPersistedCart();
      expect(cubit2.state.cartItems.length, 1);
      expect(cubit2.state.cartCount, 2);
      cubit2.close();
    });

    test('clearCart also clears SharedPreferences', () async {
      final (cubit, svc) = await _withStorage();
      cubit.addToCart(_cheap);
      await Future.delayed(Duration.zero);
      cubit.clearCart();
      await Future.delayed(Duration.zero);

      final saved = svc.loadCart();
      expect(saved, isEmpty);
      cubit.close();
    });

    test('cubit without persistence does not throw', () {
      final cubit = ShoppingCubit(); // no persistence arg
      cubit.addToCart(_cheap);
      cubit.loadPersistedCart();
      cubit.clearCart();
      expect(cubit.state.cartItems, isEmpty);
      cubit.close();
    });
  });

  // ── 6. CartPersistenceService unit tests ──────────────────────────────────
  group('CartPersistenceService', () {
    test('loadCart returns empty list when nothing saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final svc = CartPersistenceService(prefs);
      expect(svc.loadCart(), isEmpty);
    });

    test('saveCart and loadCart are symmetric', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final svc = CartPersistenceService(prefs);

      const items = [CartItem(product: _expensive, quantity: 3)];
      await svc.saveCart(items);

      final loaded = svc.loadCart();
      expect(loaded.length, 1);
      expect(loaded.first.quantity, 3);
      expect(loaded.first.product.id, _expensive.id);
      expect(loaded.first.product.originalPrice, 350.0);
    });

    test('clearCart removes stored data', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final svc = CartPersistenceService(prefs);

      await svc.saveCart([CartItem(product: _cheap)]);
      await svc.clearCart();

      expect(svc.loadCart(), isEmpty);
    });

    test('loadCart returns empty list on corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        'noon_cart_v1': '{not: valid json}',
      });
      final prefs = await SharedPreferences.getInstance();
      final svc = CartPersistenceService(prefs);
      expect(svc.loadCart(), isEmpty);
    });
  });
}
