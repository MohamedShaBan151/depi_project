import 'dart:async';

import '../models/product_model.dart';

/// Product service with a mock in-memory stream so the app works without
/// a live Firestore connection during development.
///
/// To swap to real Firestore, replace the class body with the Firestore
/// implementation (see comment at the bottom of this file).
class ProductService {
  // ── Mock data ──────────────────────────────────────────────────────────────

  static final List<ProductModel> _mockProducts = [
    const ProductModel(id: 'e1', name: 'Samsung Galaxy S24 Ultra', price: 4299, category: 'Electronics', stock: 12, imageUrl: ''),
    const ProductModel(id: 'e2', name: 'Apple AirPods Pro (2nd Gen)', price: 899, category: 'Electronics', stock: 30, imageUrl: ''),
    const ProductModel(id: 'e3', name: 'Sony 65" 4K OLED TV', price: 7499, category: 'Electronics', stock: 5, imageUrl: ''),
    const ProductModel(id: 'e4', name: 'iPad Air M2 Wi-Fi 256GB', price: 2599, category: 'Electronics', stock: 18, imageUrl: ''),
    const ProductModel(id: 'f1', name: 'Adidas Ultraboost 22 Running Shoes', price: 549, category: 'Fashion', stock: 40, imageUrl: ''),
    const ProductModel(id: 'f2', name: 'Levi\'s 511 Slim Fit Jeans', price: 299, category: 'Fashion', stock: 60, imageUrl: ''),
    const ProductModel(id: 'f3', name: 'Nike Therma-FIT Hoodie', price: 249, category: 'Fashion', stock: 35, imageUrl: ''),
    const ProductModel(id: 'f4', name: 'Ray-Ban Classic Aviator Sunglasses', price: 699, category: 'Fashion', stock: 22, imageUrl: ''),
    const ProductModel(id: 'g1', name: 'Almarai Full Cream Milk 2L', price: 12, category: 'Grocery', stock: 200, imageUrl: ''),
    const ProductModel(id: 'g2', name: 'Basmati Rice Premium 5kg', price: 45, category: 'Grocery', stock: 150, imageUrl: ''),
    const ProductModel(id: 'g3', name: 'Nescafé Gold Blend 200g', price: 68, category: 'Grocery', stock: 80, imageUrl: ''),
    const ProductModel(id: 'g4', name: 'Dates Medjool Premium 1kg', price: 89, category: 'Grocery', stock: 90, imageUrl: ''),
    const ProductModel(id: 't1', name: 'LEGO Technic Bugatti Chiron', price: 1299, category: 'Toys', stock: 8, imageUrl: ''),
    const ProductModel(id: 't2', name: 'Barbie Dreamhouse Playset', price: 549, category: 'Toys', stock: 15, imageUrl: ''),
    const ProductModel(id: 't3', name: 'Hot Wheels 20-Car Gift Pack', price: 89, category: 'Toys', stock: 60, imageUrl: ''),
    const ProductModel(id: 't4', name: 'Remote Control Monster Truck', price: 199, category: 'Toys', stock: 25, imageUrl: ''),
  ];

  // ── Stream API (matches original interface) ────────────────────────────────

  Stream<List<ProductModel>> watchProducts() {
    // Emit immediately then keep the stream open
    final controller = StreamController<List<ProductModel>>();
    controller.add(List.of(_mockProducts));
    return controller.stream;
  }

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
        id: p.id,
        name: p.name,
        price: p.price,
        category: p.category,
        stock: (p.stock + delta).clamp(0, 9999),
        imageUrl: p.imageUrl,
      );
    }
  }
}

// ── Firestore implementation (uncomment when Firebase is configured) ───────────
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ProductService {
//   final _db = FirebaseFirestore.instance;
//   static const _col = 'products';
//
//   Stream<List<ProductModel>> watchProducts() =>
//       _db.collection(_col)
//           .orderBy('createdAt', descending: true)
//           .snapshots()
//           .map((s) => s.docs.map(ProductModel.fromDoc).toList());
//
//   Future<List<ProductModel>> fetchByCategory(String category,
//       {DocumentSnapshot? lastDoc, int limit = 20}) async {
//     var q = _db.collection(_col).where('category', isEqualTo: category).limit(limit);
//     if (lastDoc != null) q = q.startAfterDocument(lastDoc);
//     final snap = await q.get();
//     return snap.docs.map(ProductModel.fromDoc).toList();
//   }
//
//   Future<void> addProduct(ProductModel product) =>
//       _db.collection(_col).add(product.toJson());
//
//   Future<void> updateStock(String id, int delta) =>
//       _db.collection(_col).doc(id).update({
//         'stock': FieldValue.increment(delta),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
// }
