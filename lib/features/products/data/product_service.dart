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
    const ProductModel(id: 'e1', name: 'Samsung Galaxy S24 Ultra',    price: 4299, originalPrice: 4799, rating: 4.8, reviewCount: 2140, category: 'Electronics', stock: 12, isFeatured: true,  imageUrl: 'https://images.unsplash.com/photo-1511707267537-b85faf00021e?w=400&h=400&fit=crop'),
    const ProductModel(id: 'e2', name: 'Apple AirPods Pro (2nd Gen)', price: 899,  originalPrice: 999,  rating: 4.7, reviewCount: 3880, category: 'Electronics', stock: 30, imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop'),
    const ProductModel(id: 'e3', name: 'Sony 65" 4K OLED TV',         price: 7499, originalPrice: 8999, rating: 4.6, reviewCount: 560,  category: 'Electronics', stock: 5,  isFeatured: true,  imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400&h=400&fit=crop'),
    const ProductModel(id: 'e4', name: 'iPad Air M2 Wi-Fi 256GB',     price: 2599,                      rating: 4.9, reviewCount: 720,  category: 'Electronics', stock: 18, imageUrl: 'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&h=400&fit=crop'),
    const ProductModel(id: 'e5', name: 'Dell XPS 15 Laptop',          price: 5499, originalPrice: 5999, rating: 4.6, reviewCount: 430,  category: 'Electronics', stock: 7,  imageUrl: 'https://images.unsplash.com/photo-1588872657840-018f262fa501?w=400&h=400&fit=crop'),
    const ProductModel(id: 'f1', name: 'Adidas Ultraboost 22',        price: 549,  originalPrice: 699,  rating: 4.5, reviewCount: 1200, category: 'Fashion',     stock: 40, imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop'),
    const ProductModel(id: 'f2', name: "Levi's 511 Slim Fit Jeans",   price: 299,                       rating: 4.4, reviewCount: 890,  category: 'Fashion',     stock: 60, imageUrl: 'https://images.unsplash.com/photo-1542272604-787c62d465d1?w=400&h=400&fit=crop'),
    const ProductModel(id: 'f3', name: 'Nike Therma-FIT Hoodie',      price: 249,  originalPrice: 319,  rating: 4.3, reviewCount: 430,  category: 'Fashion',     stock: 35, imageUrl: 'https://images.unsplash.com/photo-1556821552-5ff63b1c3e9f?w=400&h=400&fit=crop'),
    const ProductModel(id: 'f4', name: 'Ray-Ban Classic Aviator',     price: 699,                       rating: 4.7, reviewCount: 670,  category: 'Fashion',     stock: 22, imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400&h=400&fit=crop'),
    const ProductModel(id: 'f5', name: 'Puma Training Joggers',       price: 189,  originalPrice: 249,  rating: 4.2, reviewCount: 310,  category: 'Fashion',     stock: 45, imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400&h=400&fit=crop'),
    const ProductModel(id: 'g1', name: 'Almarai Full Cream Milk 2L',  price: 12,                        rating: 4.8, reviewCount: 5200, category: 'Grocery',     stock: 200, imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b25a4ff?w=400&h=400&fit=crop'),
    const ProductModel(id: 'g2', name: 'Basmati Rice Premium 5kg',    price: 45,   originalPrice: 55,   rating: 4.6, reviewCount: 3100, category: 'Grocery',     stock: 150, imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop'),
    const ProductModel(id: 'g3', name: 'Nescafé Gold Blend 200g',     price: 68,                        rating: 4.5, reviewCount: 2200, category: 'Grocery',     stock: 80, imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b3f4?w=400&h=400&fit=crop'),
    const ProductModel(id: 'g4', name: 'Dates Medjool Premium 1kg',   price: 89,   originalPrice: 110,  rating: 4.9, reviewCount: 1800, category: 'Grocery',     stock: 90, imageUrl: 'https://images.unsplash.com/photo-1585518419759-147bae67b301?w=400&h=400&fit=crop'),
    const ProductModel(id: 't1', name: 'LEGO Technic Bugatti Chiron', price: 1299, originalPrice: 1499, rating: 4.9, reviewCount: 340,  category: 'Toys',        stock: 8,  isFeatured: true,  imageUrl: 'https://images.unsplash.com/photo-1594787318286-3d835c1cab83?w=400&h=400&fit=crop'),
    const ProductModel(id: 't2', name: 'Barbie Dreamhouse Playset',   price: 549,                       rating: 4.6, reviewCount: 780,  category: 'Toys',        stock: 15, imageUrl: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=400&h=400&fit=crop'),
    const ProductModel(id: 't3', name: 'Hot Wheels 20-Car Gift Pack', price: 89,   originalPrice: 109,  rating: 4.7, reviewCount: 2100, category: 'Toys',        stock: 60, imageUrl: 'https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?w=400&h=400&fit=crop'),
    const ProductModel(id: 't4', name: 'RC Monster Truck',            price: 199,                       rating: 4.4, reviewCount: 560,  category: 'Toys',        stock: 25, imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=400&fit=crop'),
    const ProductModel(id: 'h1', name: 'Egyptian Cotton Bed Sheet Set', price: 249, originalPrice: 349, rating: 4.5, reviewCount: 890, category: 'Home', stock: 30, imageUrl: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=400&h=400&fit=crop'),
    const ProductModel(id: 'h2', name: 'Stainless Steel Cookware Set',  price: 599, originalPrice: 799, rating: 4.7, reviewCount: 450, category: 'Home', stock: 12, imageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d03b3?w=400&h=400&fit=crop'),
    const ProductModel(id: 'h3', name: 'Scented Candle Collection',     price: 89,                      rating: 4.3, reviewCount: 670, category: 'Home', stock: 55, imageUrl: 'https://images.unsplash.com/photo-1591707223326-46e9aa507732?w=400&h=400&fit=crop'),
    const ProductModel(id: 'b1', name: 'Organic Argan Oil Hair Serum',  price: 79,  originalPrice: 99,   rating: 4.4, reviewCount: 2100, category: 'Beauty', stock: 40, imageUrl: 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop'),
    const ProductModel(id: 'b2', name: 'Professional Makeup Brush Set', price: 149, originalPrice: 199,  rating: 4.6, reviewCount: 1300, category: 'Beauty', stock: 25, imageUrl: 'https://images.unsplash.com/photo-1596462502278-af396f25c5e7?w=400&h=400&fit=crop'),
    const ProductModel(id: 'b3', name: 'Vitamin C Brightening Cream',   price: 59,                      rating: 4.2, reviewCount: 3400, category: 'Beauty', stock: 70, imageUrl: 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400&h=400&fit=crop'),
    const ProductModel(id: 's1', name: 'Nike Pro Training Gear Set',    price: 299, originalPrice: 399,  rating: 4.5, reviewCount: 560, category: 'Sports', stock: 20, imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=400&h=400&fit=crop'),
    const ProductModel(id: 's2', name: 'Yoga Mat Premium Non-Slip',     price: 129,                     rating: 4.6, reviewCount: 890, category: 'Sports', stock: 35, imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25ddfcbf042?w=400&h=400&fit=crop'),
    const ProductModel(id: 'bk1', name: 'Atomic Habits by James Clear',  price: 59,  originalPrice: 79,   rating: 4.9, reviewCount: 12000, category: 'Books', stock: 100, imageUrl: 'https://images.unsplash.com/photo-1507842217343-583f20270319?w=400&h=400&fit=crop'),
    const ProductModel(id: 'bk2', name: 'Rich Dad Poor Dad',             price: 45,                      rating: 4.7, reviewCount: 8500, category: 'Books', stock: 80, imageUrl: 'https://images.unsplash.com/photo-1507842217343-583f20270319?w=400&h=400&fit=crop'),
    const ProductModel(id: 'a1', name: 'Car Phone Holder Mount',         price: 39,  originalPrice: 59,   rating: 4.3, reviewCount: 2300, category: 'Automotive', stock: 65, imageUrl: 'https://images.unsplash.com/photo-1609042231691-32eae69a87d1?w=400&h=400&fit=crop'),
    const ProductModel(id: 'a2', name: 'Microfiber Car Cleaning Kit',    price: 89,                      rating: 4.4, reviewCount: 1200, category: 'Automotive', stock: 40, imageUrl: 'https://images.unsplash.com/photo-1590771033100-9f60a05a2d6b?w=400&h=400&fit=crop'),
    const ProductModel(id: 'he1', name: 'Digital Blood Pressure Monitor', price: 129, originalPrice: 169, rating: 4.5, reviewCount: 980, category: 'Health', stock: 30, imageUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400&h=400&fit=crop'),
    const ProductModel(id: 'he2', name: 'Essential Oil Diffuser',        price: 69,                      rating: 4.3, reviewCount: 1500, category: 'Health', stock: 50, imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&h=400&fit=crop'),
    const ProductModel(id: 'ba1', name: 'Baby Stroller Ultra Light',     price: 599, originalPrice: 799, rating: 4.6, reviewCount: 340, category: 'Baby', stock: 10, isFeatured: true, imageUrl: 'https://images.unsplash.com/photo-1555014709-d4b604f0c90d?w=400&h=400&fit=crop'),
    const ProductModel(id: 'ba2', name: 'Baby Diaper Mega Pack Size 4',  price: 149,                     rating: 4.7, reviewCount: 4200, category: 'Baby', stock: 200, imageUrl: 'https://images.unsplash.com/photo-1634744771-00a2b1b22d11?w=400&h=400&fit=crop'),
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
