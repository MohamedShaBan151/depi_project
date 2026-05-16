// test/data/repositories/cart_cubit_test.dart
// ─────────────────────────────────────────────────────────────────────────────
// Unit tests for CartCubit. Uses mocktail to mock CartRepository.
// Run: flutter test test/data/repositories/cart_cubit_test.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:noon_clone/data/models/cart_item_model.dart';
import 'package:noon_clone/data/repositories/cart_repository.dart';
import 'package:noon_clone/features/products/presentation/cubit/cart_cubit.dart';

// ── Mock ──────────────────────────────────────────────────────────────────────

class MockCartRepository extends Mock implements CartRepository {}

CartItemModel _item({String id = 'item1', int qty = 1}) => CartItemModel(
      id: id,
      productId: 'p1',
      productTitle: 'Test Product',
      imageUrl: '',
      price: 99.0,
      quantity: qty,
      addedAt: DateTime(2025),
    );

void main() {
  late MockCartRepository repo;

  setUp(() {
    repo = MockCartRepository();
  });

  group('CartCubit — guest mode', () {
    blocTest<CartCubit, CartState>(
      'addItem in guest mode emits CartLoaded with the item',
      build: () => CartCubit(repo),
      act: (cubit) => cubit.addItem(_item()),
      expect: () => [
        isA<CartLoaded>().having((s) => s.items.length, 'length', 1),
      ],
    );

    blocTest<CartCubit, CartState>(
      'removeItem in guest mode removes the item',
      build: () => CartCubit(repo),
      seed: () => CartLoaded([_item()]),
      act: (cubit) => cubit.removeItem('item1'),
      expect: () => [
        isA<CartLoaded>().having((s) => s.items, 'items', isEmpty),
      ],
    );

    blocTest<CartCubit, CartState>(
      'clearCart in guest mode emits empty CartLoaded',
      build: () => CartCubit(repo),
      seed: () => CartLoaded([_item(), _item(id: 'item2')]),
      act: (cubit) => cubit.clearCart(),
      expect: () => [const CartLoaded([])],
    );
  });

  group('CartCubit — authenticated mode', () {
    const uid = 'user123';

    setUp(() {
      // watchCart returns a stream with one item.
      when(() => repo.watchCart(uid)).thenAnswer(
        (_) => Stream.value([_item()]),
      );
      when(() => repo.mergeGuestCart(uid, any())).thenAnswer((_) async {});
    });

    blocTest<CartCubit, CartState>(
      'onUserSignedIn starts stream and emits CartLoaded',
      build: () => CartCubit(repo),
      act: (cubit) => cubit.onUserSignedIn(uid),
      expect: () => [
        isA<CartLoading>(),
        isA<CartLoaded>().having((s) => s.items.length, 'length', 1),
      ],
    );

    blocTest<CartCubit, CartState>(
      'onUserSignedOut emits empty CartLoaded',
      build: () => CartCubit(repo),
      seed: () => CartLoaded([_item()]),
      act: (cubit) => cubit.onUserSignedOut(),
      expect: () => [const CartLoaded([])],
    );

    blocTest<CartCubit, CartState>(
      'addItem delegates to repo',
      setUp: () {
        when(() => repo.addItem(uid, any())).thenAnswer((_) async {});
        // After add, stream sends updated list.
        when(() => repo.watchCart(uid)).thenAnswer(
          (_) => Stream.value([_item(), _item(id: 'item2')]),
        );
      },
      build: () => CartCubit(repo),
      act: (cubit) async {
        await cubit.onUserSignedIn(uid);
        await cubit.addItem(_item(id: 'item2'));
      },
      expect: () => [
        isA<CartLoading>(),
        isA<CartLoaded>(),
        // After add, the stream update arrives.
        isA<CartLoaded>().having((s) => s.items.length, 'length', 2),
      ],
      verify: (_) => verify(() => repo.addItem(uid, any())).called(1),
    );
  });

  group('CartLoaded helpers', () {
    test('subtotal sums item subtotals', () {
      final state = CartLoaded([_item(qty: 2), _item(id: 'item2', qty: 3)]);
      expect(state.subtotal, 99.0 * 2 + 99.0 * 3);
    });

    test('totalQty sums quantities', () {
      final state = CartLoaded([_item(qty: 2), _item(id: 'item2', qty: 3)]);
      expect(state.totalQty, 5);
    });
  });
}
