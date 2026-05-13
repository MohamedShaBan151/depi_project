import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'models/order_model.dart';

class OrderFirestoreService {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  String get _collection => 'orders';

  Future<void> saveOrder(FirestoreOrder order) async {
    await _firestore.collection(_collection).doc(order.id).set(order.toJson());
  }

  Stream<List<FirestoreOrder>> watchOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirestoreOrder.fromJson(doc.data()))
            .toList());
  }

  Future<List<FirestoreOrder>> loadOrders(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FirestoreOrder.fromJson(doc.data()))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection(_collection).doc(orderId).update({
      'status': status.name,
    });
  }

  Stream<FirestoreOrder?> watchOrder(String orderId) {
    return _firestore
        .collection(_collection)
        .doc(orderId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? FirestoreOrder.fromJson(snapshot.data()!) : null);
  }
}
