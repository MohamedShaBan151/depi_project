// lib/data/repositories/cart_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// /users/{userId}/cart/{cartItemId}
// Strategy: snapshots() stream — cart must sync across devices (plan §2.4)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

abstract class CartRepository {
  Stream<List<CartItemModel>> watchCart(String userId);
  Future<void> addItem(String userId, CartItemModel item);
  Future<void> updateQuantity(String userId, String itemId, int quantity);
  Future<void> removeItem(String userId, String itemId);
  Future<void> clearCart(String userId);
  Future<void> mergeGuestCart(
      String userId, List<CartItemModel> guestItems);
}

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _cartCol(String userId) =>
      _db.collection('users').doc(userId).collection('cart');

  @override
  Stream<List<CartItemModel>> watchCart(String userId) {
    return _cartCol(userId)
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map(CartItemModel.fromFirestore).toList());
  }

  @override
  Future<void> addItem(String userId, CartItemModel item) async {
    // Check if same product+variant already in cart; if so, increment qty.
    final existing = await _cartCol(userId)
        .where('productId', isEqualTo: item.productId)
        .where('variantId', isEqualTo: item.variantId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = (doc.data()['quantity'] as int?) ?? 1;
      await doc.reference
          .update({'quantity': currentQty + item.quantity});
    } else {
      await _cartCol(userId).add(item.toFirestore());
    }
  }

  @override
  Future<void> updateQuantity(
      String userId, String itemId, int quantity) async {
    if (quantity <= 0) {
      return removeItem(userId, itemId);
    }
    await _cartCol(userId).doc(itemId).update({'quantity': quantity});
  }

  @override
  Future<void> removeItem(String userId, String itemId) async {
    await _cartCol(userId).doc(itemId).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    final snap = await _cartCol(userId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> mergeGuestCart(
      String userId, List<CartItemModel> guestItems) async {
    final batch = _db.batch();
    for (final item in guestItems) {
      final ref = _cartCol(userId).doc();
      batch.set(ref, item.toFirestore());
    }
    await batch.commit();
  }
}
