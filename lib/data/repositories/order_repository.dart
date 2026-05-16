// lib/data/repositories/order_repository.dart
// ─────────────────────────────────────────────────────────────────────────────
// /orders/{orderId}
// Strategy: snapshots() for order status (live tracking); create via
// transaction so inventory is decremented atomically (plan §2.4, §2.5)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_firestore_model.dart';

abstract class OrderRepository {
  Stream<List<OrderFirestoreModel>> watchUserOrders(String userId);
  Future<OrderFirestoreModel?> fetchById(String orderId);
  Future<String> createOrder(OrderFirestoreModel order);
  Future<void> cancelOrder(String orderId);
}

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('orders');

  @override
  Stream<List<OrderFirestoreModel>> watchUserOrders(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(OrderFirestoreModel.fromFirestore).toList());
  }

  @override
  Future<OrderFirestoreModel?> fetchById(String orderId) async {
    final doc = await _col.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderFirestoreModel.fromFirestore(doc);
  }

  @override
  Future<String> createOrder(OrderFirestoreModel order) async {
    // Use a transaction so inventory is checked and decremented atomically.
    final docRef = _col.doc();
    await _db.runTransaction((txn) async {
      // Decrement inventory for each item.
      for (final item in order.items) {
        final invQuery = await _db
            .collection('product')
            .doc(item.productId)
            .collection('inventory')
            .limit(1)
            .get();

        if (invQuery.docs.isNotEmpty) {
          final invDoc = invQuery.docs.first;
          final available =
              invDoc.data()['quantityAvailable'] as int? ?? 0;
          final trackInventory =
              invDoc.data()['trackInventory'] as bool? ?? true;

          if (trackInventory && available < item.qty) {
            throw Exception(
                'Insufficient stock for product ${item.productId}');
          }
          if (trackInventory) {
            txn.update(invDoc.reference, {
              'quantityAvailable': FieldValue.increment(-item.qty),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      // Write the order document.
      txn.set(docRef, order.toFirestore());
    });
    return docRef.id;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _col.doc(orderId).update({
      'status': FsOrderStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
