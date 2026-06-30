import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchProducts();
  Future<List<Product>> fetchByCategory(String category, {int limit});
}
