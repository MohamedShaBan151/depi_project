// ─────────────────────────────────────────────────────────────────────────────
// models.dart  –  Unified model file (Product · CartItem · User)
//
// Grouping all three models here cuts import noise across the feature
// layer and keeps the token budget lean.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

// ── Product ──────────────────────────────────────────────────────────────────

class Product extends Equatable {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice; // null → no discount badge
  final double rating;        // 0-5
  final int reviewCount;
  final int stock;
  final String imageUrl;      // swap for a real URL / asset path
  final bool isFeatured;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    this.rating = 4.0,
    this.reviewCount = 0,
    required this.stock,
    this.imageUrl = '',
    this.isFeatured = false,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  @override
  List<Object?> get props => [id];
}

// ── CartItem ─────────────────────────────────────────────────────────────────

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product.id];
}

// ── User ─────────────────────────────────────────────────────────────────────

class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String? avatarUrl;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [uid];
}

// ── Mock data ─────────────────────────────────────────────────────────────────

abstract final class MockData {
  static const List<Product> products = [
    // Electronics
    Product(id: 'e1', name: 'Samsung Galaxy S24 Ultra',    category: 'Electronics', price: 4299, originalPrice: 4799, rating: 4.8, reviewCount: 2140, stock: 12, isFeatured: true),
    Product(id: 'e2', name: 'Apple AirPods Pro (2nd Gen)', category: 'Electronics', price: 899,  originalPrice: 999,  rating: 4.7, reviewCount: 3880, stock: 30),
    Product(id: 'e3', name: 'Sony 65″ 4K OLED TV',         category: 'Electronics', price: 7499, originalPrice: 8999, rating: 4.6, reviewCount: 560,  stock: 5,  isFeatured: true),
    Product(id: 'e4', name: 'iPad Air M2 Wi-Fi 256 GB',    category: 'Electronics', price: 2599,                      rating: 4.9, reviewCount: 720,  stock: 18),
    // Fashion
    Product(id: 'f1', name: 'Adidas Ultraboost 22',        category: 'Fashion',     price: 549,  originalPrice: 699,  rating: 4.5, reviewCount: 1200, stock: 40),
    Product(id: 'f2', name: "Levi's 511 Slim Fit Jeans",   category: 'Fashion',     price: 299,                       rating: 4.4, reviewCount: 890,  stock: 60),
    Product(id: 'f3', name: 'Nike Therma-FIT Hoodie',      category: 'Fashion',     price: 249,  originalPrice: 319,  rating: 4.3, reviewCount: 430,  stock: 35),
    Product(id: 'f4', name: 'Ray-Ban Aviator Classic',     category: 'Fashion',     price: 699,                       rating: 4.7, reviewCount: 670,  stock: 22),
    // Grocery
    Product(id: 'g1', name: 'Almarai Full Cream Milk 2L',  category: 'Grocery',     price: 12,                        rating: 4.8, reviewCount: 5200, stock: 200),
    Product(id: 'g2', name: 'Basmati Rice Premium 5 kg',   category: 'Grocery',     price: 45,   originalPrice: 55,   rating: 4.6, reviewCount: 3100, stock: 150),
    Product(id: 'g3', name: 'Nescafé Gold Blend 200 g',    category: 'Grocery',     price: 68,                        rating: 4.5, reviewCount: 2200, stock: 80),
    Product(id: 'g4', name: 'Medjool Dates Premium 1 kg',  category: 'Grocery',     price: 89,   originalPrice: 110,  rating: 4.9, reviewCount: 1800, stock: 90),
    // Toys
    Product(id: 't1', name: 'LEGO Technic Bugatti Chiron', category: 'Toys',        price: 1299, originalPrice: 1499, rating: 4.9, reviewCount: 340,  stock: 8,  isFeatured: true),
    Product(id: 't2', name: 'Barbie Dreamhouse Playset',   category: 'Toys',        price: 549,                       rating: 4.6, reviewCount: 780,  stock: 15),
    Product(id: 't3', name: 'Hot Wheels 20-Car Gift Pack', category: 'Toys',        price: 89,   originalPrice: 109,  rating: 4.7, reviewCount: 2100, stock: 60),
    Product(id: 't4', name: 'RC Monster Truck',            category: 'Toys',        price: 199,                       rating: 4.4, reviewCount: 560,  stock: 25),
  ];

  static const User currentUser = User(
    uid: 'mock-001',
    name: 'Ahmed Al-Rashidi',
    email: 'ahmed@example.sa',
  );
}
