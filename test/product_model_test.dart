import 'package:flutter_test/flutter_test.dart';
import 'package:noon_clone/features/products/models/product_model.dart';

void main() {
  group('ProductModel.toEntity (Bug #15)', () {
    test('preserves originalPrice', () {
      final model = const ProductModel(
        id: 'e1', name: 'Test', price: 100,
        category: 'Electronics', stock: 5, imageUrl: '',
        originalPrice: 150,
      );
      final entity = model.toEntity();
      expect(entity.originalPrice, 150);
    });

    test('preserves rating', () {
      final model = const ProductModel(
        id: 'e1', name: 'Test', price: 100,
        category: 'Electronics', stock: 5, imageUrl: '',
        rating: 4.7,
      );
      expect(model.toEntity().rating, 4.7);
    });

    test('preserves isFeatured', () {
      final model = const ProductModel(
        id: 'e1', name: 'Test', price: 100,
        category: 'Electronics', stock: 5, imageUrl: '',
        isFeatured: true,
      );
      expect(model.toEntity().isFeatured, isTrue);
    });

    test('preserves stock', () {
      final model = const ProductModel(
        id: 'e1', name: 'Test', price: 100,
        category: 'Electronics', stock: 42, imageUrl: '',
      );
      expect(model.toEntity().stock, 42);
    });
  });
}
