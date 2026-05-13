import 'dart:async';
import '../models/product_model.dart';

class ProductService {
  static const List<String> categories = [
    'All',
    'Electronics',
    'Fashion',
    'Grocery',
    'Toys',
    'Home',
    'Beauty',
    'Sports',
    'Books',
    'Automotive',
    'Health',
    'Baby',
  ];

  static final List<ProductModel> _mockProducts = [
    const ProductModel(id: 'e1', name: 'Samsung Galaxy S24 Ultra',    price: 4299, originalPrice: 4799, rating: 4.8, reviewCount: 2140, category: 'Electronics', stock: 12, isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 'e2', name: 'Apple AirPods Pro (2nd Gen)', price: 899,  originalPrice: 999,  rating: 4.7, reviewCount: 3880, category: 'Electronics', stock: 30, imageUrl: ''),
    const ProductModel(id: 'e3', name: 'Sony 65" 4K OLED TV',         price: 7499, originalPrice: 8999, rating: 4.6, reviewCount: 560,  category: 'Electronics', stock: 5,  isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 'e4', name: 'iPad Air M2 Wi-Fi 256GB',     price: 2599,                      rating: 4.9, reviewCount: 720,  category: 'Electronics', stock: 18, imageUrl: ''),
    const ProductModel(id: 'e5', name: 'Dell XPS 15 Laptop',          price: 5499, originalPrice: 5999, rating: 4.6, reviewCount: 430,  category: 'Electronics', stock: 7,  imageUrl: ''),
    const ProductModel(id: 'f1', name: 'Adidas Ultraboost 22',        price: 549,  originalPrice: 699,  rating: 4.5, reviewCount: 1200, category: 'Fashion',     stock: 40, imageUrl: ''),
    const ProductModel(id: 'f2', name: "Levi's 511 Slim Fit Jeans",   price: 299,                       rating: 4.4, reviewCount: 890,  category: 'Fashion',     stock: 60, imageUrl: ''),
    const ProductModel(id: 'f3', name: 'Nike Therma-FIT Hoodie',      price: 249,  originalPrice: 319,  rating: 4.3, reviewCount: 430,  category: 'Fashion',     stock: 35, imageUrl: ''),
    const ProductModel(id: 'f4', name: 'Ray-Ban Classic Aviator',     price: 699,                       rating: 4.7, reviewCount: 670,  category: 'Fashion',     stock: 22, imageUrl: ''),
    const ProductModel(id: 'f5', name: 'Puma Training Joggers',       price: 189,  originalPrice: 249,  rating: 4.2, reviewCount: 310,  category: 'Fashion',     stock: 45, imageUrl: ''),
    const ProductModel(id: 'g1', name: 'Almarai Full Cream Milk 2L',  price: 12,                        rating: 4.8, reviewCount: 5200, category: 'Grocery',     stock: 200,imageUrl: ''),
    const ProductModel(id: 'g2', name: 'Basmati Rice Premium 5kg',    price: 45,   originalPrice: 55,   rating: 4.6, reviewCount: 3100, category: 'Grocery',     stock: 150,imageUrl: ''),
    const ProductModel(id: 'g3', name: 'Nescafé Gold Blend 200g',     price: 68,                        rating: 4.5, reviewCount: 2200, category: 'Grocery',     stock: 80, imageUrl: ''),
    const ProductModel(id: 'g4', name: 'Dates Medjool Premium 1kg',   price: 89,   originalPrice: 110,  rating: 4.9, reviewCount: 1800, category: 'Grocery',     stock: 90, imageUrl: ''),
    const ProductModel(id: 't1', name: 'LEGO Technic Bugatti Chiron', price: 1299, originalPrice: 1499, rating: 4.9, reviewCount: 340,  category: 'Toys',        stock: 8,  isFeatured: true,  imageUrl: ''),
    const ProductModel(id: 't2', name: 'Barbie Dreamhouse Playset',   price: 549,                       rating: 4.6, reviewCount: 780,  category: 'Toys',        stock: 15, imageUrl: ''),
    const ProductModel(id: 't3', name: 'Hot Wheels 20-Car Gift Pack', price: 89,   originalPrice: 109,  rating: 4.7, reviewCount: 2100, category: 'Toys',        stock: 60, imageUrl: ''),
    const ProductModel(id: 't4', name: 'RC Monster Truck',            price: 199,                       rating: 4.4, reviewCount: 560,  category: 'Toys',        stock: 25, imageUrl: ''),
    const ProductModel(id: 'h1', name: 'Egyptian Cotton Bed Sheet Set', price: 249, originalPrice: 349, rating: 4.5, reviewCount: 890, category: 'Home', stock: 30, imageUrl: ''),
    const ProductModel(id: 'h2', name: 'Stainless Steel Cookware Set',  price: 599, originalPrice: 799, rating: 4.7, reviewCount: 450, category: 'Home', stock: 12, imageUrl: ''),
    const ProductModel(id: 'h3', name: 'Scented Candle Collection',     price: 89,                      rating: 4.3, reviewCount: 670, category: 'Home', stock: 55, imageUrl: ''),
    const ProductModel(id: 'b1', name: 'Organic Argan Oil Hair Serum',  price: 79,  originalPrice: 99,   rating: 4.4, reviewCount: 2100, category: 'Beauty', stock: 40, imageUrl: ''),
    const ProductModel(id: 'b2', name: 'Professional Makeup Brush Set', price: 149, originalPrice: 199,  rating: 4.6, reviewCount: 1300, category: 'Beauty', stock: 25, imageUrl: ''),
    const ProductModel(id: 'b3', name: 'Vitamin C Brightening Cream',   price: 59,                      rating: 4.2, reviewCount: 3400, category: 'Beauty', stock: 70, imageUrl: ''),
    const ProductModel(id: 's1', name: 'Nike Pro Training Gear Set',    price: 299, originalPrice: 399,  rating: 4.5, reviewCount: 560, category: 'Sports', stock: 20, imageUrl: ''),
    const ProductModel(id: 's2', name: 'Yoga Mat Premium Non-Slip',     price: 129,                     rating: 4.6, reviewCount: 890, category: 'Sports', stock: 35, imageUrl: ''),
    const ProductModel(id: 'bk1', name: 'Atomic Habits by James Clear',  price: 59,  originalPrice: 79,   rating: 4.9, reviewCount: 12000, category: 'Books', stock: 100, imageUrl: ''),
    const ProductModel(id: 'bk2', name: 'Rich Dad Poor Dad',             price: 45,                      rating: 4.7, reviewCount: 8500, category: 'Books', stock: 80, imageUrl: ''),
    const ProductModel(id: 'a1', name: 'Car Phone Holder Mount',         price: 39,  originalPrice: 59,   rating: 4.3, reviewCount: 2300, category: 'Automotive', stock: 65, imageUrl: ''),
    const ProductModel(id: 'a2', name: 'Microfiber Car Cleaning Kit',    price: 89,                      rating: 4.4, reviewCount: 1200, category: 'Automotive', stock: 40, imageUrl: ''),
    const ProductModel(id: 'he1', name: 'Digital Blood Pressure Monitor', price: 129, originalPrice: 169, rating: 4.5, reviewCount: 980, category: 'Health', stock: 30, imageUrl: ''),
    const ProductModel(id: 'he2', name: 'Essential Oil Diffuser',        price: 69,                      rating: 4.3, reviewCount: 1500, category: 'Health', stock: 50, imageUrl: ''),
    const ProductModel(id: 'ba1', name: 'Baby Stroller Ultra Light',     price: 599, originalPrice: 799, rating: 4.6, reviewCount: 340, category: 'Baby', stock: 10, isFeatured: true, imageUrl: ''),
    const ProductModel(id: 'ba2', name: 'Baby Diaper Mega Pack Size 4',  price: 149,                     rating: 4.7, reviewCount: 4200, category: 'Baby', stock: 200, imageUrl: ''),
  ];

  Stream<List<ProductModel>> watchProducts() =>
      Stream.fromIterable([List.of(_mockProducts)]);

  Future<List<ProductModel>> fetchByCategory(
    String category, {
    Object? lastDoc,
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final filtered = category == 'All'
        ? _mockProducts
        : _mockProducts.where((p) => p.category == category).toList();
    return filtered.take(limit).toList();
  }

  Future<List<ProductModel>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var results = _mockProducts.where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase())).toList();
    if (category != null && category != 'All') {
      results = results.where((p) => p.category == category).toList();
    }
    if (minPrice != null) {
      results = results.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((p) => p.price <= maxPrice).toList();
    }
    if (minRating != null) {
      results = results.where((p) => p.rating >= minRating).toList();
    }
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          results.sort((a, b) => a.price.compareTo(b.price));
        case 'price_desc':
          results.sort((a, b) => b.price.compareTo(a.price));
        case 'rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
        case 'popular':
          results.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        case 'name':
          results.sort((a, b) => a.name.compareTo(b.name));
      }
    }
    return results;
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
