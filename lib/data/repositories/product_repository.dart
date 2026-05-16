// lib/data/repositories/product_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// Reads /product (singular — as named in Firestore) and its subcollections.
// Strategy: get() once + cursor pagination for listing (plan §2.4)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_firestore_full.dart';

abstract class ProductRepository {
  Future<List<ProductFull>> fetchByCategory(
    String categoryId, {
    DocumentSnapshot? startAfter,
    int limit,
  });

  Future<List<ProductFull>> searchProducts(String query, {int limit});

  Future<ProductFull?> fetchById(String productId);

  Future<ProductInventory?> fetchInventory(String productId);

  Future<List<ProductReview>> fetchReviews(
    String productId, {
    DocumentSnapshot? startAfter,
    int limit,
  });

  Future<List<ProductVariant>> fetchVariants(String productId);

  Future<void> addReview(String productId, ProductReview review);
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // Firestore collection is named 'product' (singular) per the plan
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('product');

  @override
  Future<List<ProductFull>> fetchByCategory(
    String categoryId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .where('categoryId', isEqualTo: categoryId)
        .where('isDeleted', isEqualTo: false)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(ProductFull.fromFirestore).toList();
  }

  @override
  Future<List<ProductFull>> searchProducts(String query,
      {int limit = 20}) async {
    // Firestore doesn't support full-text search natively.
    // Use tags array-contains-any for simple keyword matching.
    // For production, integrate Algolia or Typesense.
    final snap = await _col
        .where('tags', arrayContains: query.toLowerCase())
        .where('isDeleted', isEqualTo: false)
        .limit(limit)
        .get();
    return snap.docs.map(ProductFull.fromFirestore).toList();
  }

  @override
  Future<ProductFull?> fetchById(String productId) async {
    final doc = await _col.doc(productId).get();
    if (!doc.exists) return null;
    return ProductFull.fromFirestore(doc);
  }

  @override
  Future<ProductInventory?> fetchInventory(String productId) async {
    final snap =
        await _col.doc(productId).collection('inventory').limit(1).get();
    if (snap.docs.isEmpty) return null;
    return ProductInventory.fromFirestore(snap.docs.first);
  }

  @override
  Future<List<ProductReview>> fetchReviews(
    String productId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> q = _col
        .doc(productId)
        .collection('reviews')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap.docs.map(ProductReview.fromFirestore).toList();
  }

  @override
  Future<List<ProductVariant>> fetchVariants(String productId) async {
    final snap =
        await _col.doc(productId).collection('variants').get();
    return snap.docs.map(ProductVariant.fromFirestore).toList();
  }

  @override
  Future<void> addReview(String productId, ProductReview review) async {
    await _col
        .doc(productId)
        .collection('reviews')
        .add(review.toFirestore());
  }
}
