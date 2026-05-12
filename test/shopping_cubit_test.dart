import 'package:flutter_test/flutter_test.dart';
import 'package:noon_clone/cubits/shopping_cubit.dart';
import 'package:noon_clone/data/models/models.dart';

const _product = Product(
  id: 'p1', name: 'Test Product', category: 'Electronics',
  price: 100, stock: 10,
);

void main() {
  group('ShoppingCubit cart operations', () {
    late ShoppingCubit cubit;

    setUp(() => cubit = ShoppingCubit()); // no storage — tests in-memory

    test('addToCart increments count', () {
      cubit.addToCart(_product);
      expect(cubit.state.cartCount, 1);
    });

    test('addToCart twice → quantity 2', () {
      cubit.addToCart(_product);
      cubit.addToCart(_product);
      expect(cubit.state.cartCount, 2);
      expect(cubit.state.cartItems.length, 1);
    });

    test('removeFromCart decrements quantity', () {
      cubit.addToCart(_product);
      cubit.addToCart(_product);
      cubit.removeFromCart('p1');
      expect(cubit.state.cartCount, 1);
    });

    test('removeFromCart removes item when quantity reaches 0', () {
      cubit.addToCart(_product);
      cubit.removeFromCart('p1');
      expect(cubit.state.cartItems, isEmpty);
    });

    test('clearCart empties the cart', () {
      cubit.addToCart(_product);
      cubit.clearCart();
      expect(cubit.state.cartCount, 0);
    });
  });

  group('ShoppingCubit product_cubit integration (Bug #3)', () {
    test('product fields survive addToCart round-trip', () {
      final cubit = ShoppingCubit();
      const richProduct = Product(
        id: 'r1', name: 'Rich', category: 'Fashion',
        price: 200, originalPrice: 250, stock: 5,
        rating: 4.8, reviewCount: 120, isFeatured: true,
      );
      cubit.addToCart(richProduct);
      final item = cubit.state.cartItems.first;
      expect(item.product.originalPrice, 250);
      expect(item.product.rating, 4.8);
      expect(item.product.isFeatured, isTrue);
    });
  });
}
