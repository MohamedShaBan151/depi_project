import 'dart:async';
import '../models/product_model.dart';

class ProductService {
  static final List<ProductModel> _mockProducts = [
    const ProductModel(id: 'e1', name: 'Samsung Galaxy S24 Ultra',    price: 4299, originalPrice: 4799, rating: 4.8, reviewCount: 2140, category: 'Electronics', stock: 12, isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 'e2', name: 'Apple AirPods Pro (2nd Gen)', price: 899,  originalPrice: 999,  rating: 4.7, reviewCount: 3880, category: 'Electronics', stock: 30, imageUrl: ''),
    const ProductModel(id: 'e3', name: 'Sony 65" 4K OLED TV',         price: 7499, originalPrice: 8999, rating: 4.6, reviewCount: 560,  category: 'Electronics', stock: 5,  isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 'e4', name: 'iPad Air M2 Wi-Fi 256GB',     price: 2599,                      rating: 4.9, reviewCount: 720,  category: 'Electronics', stock: 18, imageUrl: ''),
    const ProductModel(id: 'f1', name: 'Adidas Ultraboost 22',        price: 549,  originalPrice: 699,  rating: 4.5, reviewCount: 1200, category: 'Fashion',     stock: 40, imageUrl: ''),
    const ProductModel(id: 'f2', name: "Levi's 511 Slim Fit Jeans",   price: 299,                       rating: 4.4, reviewCount: 890,  category: 'Fashion',     stock: 60, imageUrl: ''),
    const ProductModel(id: 'f3', name: 'Nike Therma-FIT Hoodie',      price: 249,  originalPrice: 319,  rating: 4.3, reviewCount: 430,  category: 'Fashion',     stock: 35, imageUrl: ''),
    const ProductModel(id: 'f4', name: 'Ray-Ban Classic Aviator',     price: 699,                       rating: 4.7, reviewCount: 670,  category: 'Fashion',     stock: 22, imageUrl: ''),
    const ProductModel(id: 'g1', name: 'Almarai Full Cream Milk 2L',  price: 12,                        rating: 4.8, reviewCount: 5200, category: 'Grocery',     stock: 200,imageUrl: ''),
    const ProductModel(id: 'g2', name: 'Basmati Rice Premium 5kg',    price: 45,   originalPrice: 55,   rating: 4.6, reviewCount: 3100, category: 'Grocery',     stock: 150,imageUrl: ''),
    const ProductModel(id: 'g3', name: 'Nescafé Gold Blend 200g',     price: 68,                        rating: 4.5, reviewCount: 2200, category: 'Grocery',     stock: 80, imageUrl: ''),
    const ProductModel(id: 'g4', name: 'Dates Medjool Premium 1kg',   price: 89,   originalPrice: 110,  rating: 4.9, reviewCount: 1800, category: 'Grocery',     stock: 90, imageUrl: ''),
    const ProductModel(id: 't1', name: 'LEGO Technic Bugatti Chiron', price: 1299, originalPrice: 1499, rating: 4.9, reviewCount: 340,  category: 'Toys',        stock: 8,  isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 't2', name: 'Barbie Dreamhouse Playset',   price: 549,                       rating: 4.6, reviewCount: 780,  category: 'Toys',        stock: 15, imageUrl: ''),
    const ProductModel(id: 't3', name: 'Hot Wheels 20-Car Gift Pack', price: 89,   originalPrice: 109,  rating: 4.7, reviewCount: 2100, category: 'Toys',        stock: 60, imageUrl: ''),
    const ProductModel(id: 't4', name: 'RC Monster Truck',            price: 199,                       rating: 4.4, reviewCount: 560,  category: 'Toys',        stock: 25, imageUrl: ''),
  ];

  // FIX (Bug #13): original used an unclosed StreamController → memory leak.
  Stream<List<ProductModel>> watchProducts() =>
      Stream.fromIterable([List.of(_mockProducts)]);

  Future<List<ProductModel>> fetchByCategory(
    String category, {
    Object? lastDoc,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered = category == 'All'
        ? _mockProducts
        : _mockProducts.where((p) => p.category == category).toList();
    return filtered.take(limit).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    _mockProducts.add(product);
  }

  Future<void> updateStock(String id, int delta) async {
    final idx = _mockProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final p = _mockProducts[idx];
      _mockProducts[idx] = ProductModel(
        id: p.id, name: p.name, price: p.price, category: p.category,
        stock: (p.stock + delta).clamp(0, 9999), imageUrl: p.imageUrl,
        originalPrice: p.originalPrice, rating: p.rating,
        reviewCount: p.reviewCount, isFeatured: p.isFeatured,
      );
    }
  }
}
