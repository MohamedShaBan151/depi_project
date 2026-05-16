import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/return_model.dart';

/// Service for managing product returns and refunds
class ReturnService {
  static const String _collectionName = 'returns';

  final FirebaseFirestore _firestore;

  ReturnService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a return request
  Future<String> createReturnRequest({
    required ReturnRequestModel returnRequest,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final requestWithId = returnRequest.copyWith(id: docRef.id);

      await docRef.set(requestWithId.toJson());
      return docRef.id;
    } catch (e) {
      throw ReturnServiceException('Failed to create return request: $e');
    }
  }

  /// Get return requests for a user
  Future<List<ReturnRequestModel>> getUserReturns(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              ReturnRequestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ReturnServiceException('Failed to get user returns: $e');
    }
  }

  /// Get return requests for a specific order
  Future<List<ReturnRequestModel>> getOrderReturns(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('orderId', isEqualTo: orderId)
          .get();

      return snapshot.docs
          .map((doc) =>
              ReturnRequestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ReturnServiceException('Failed to get order returns: $e');
    }
  }

  /// Stream user's return requests for real-time updates
  Stream<List<ReturnRequestModel>> watchUserReturns(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  ReturnRequestModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ReturnServiceException('Failed to watch user returns: $e');
    }
  }

  /// Get a specific return request
  Future<ReturnRequestModel?> getReturnRequest(String returnId) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(returnId).get();

      if (!doc.exists) return null;

      return ReturnRequestModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw ReturnServiceException('Failed to get return request: $e');
    }
  }

  /// Update return request status
  Future<void> updateReturnStatus({
    required String returnId,
    required ReturnStatus status,
    String? trackingNumber,
  }) async {
    try {
      final updates = {
        'returnStatus': status.name,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (status == ReturnStatus.approved)
          'approvedAt': DateTime.now().toIso8601String(),
        if (status == ReturnStatus.shipped)
          'shippedAt': DateTime.now().toIso8601String(),
        if (status == ReturnStatus.received)
          'receivedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(_collectionName)
          .doc(returnId)
          .update(updates);
    } catch (e) {
      throw ReturnServiceException('Failed to update return status: $e');
    }
  }

  /// Update refund status
  Future<void> updateRefundStatus({
    required String returnId,
    required RefundStatus status,
  }) async {
    try {
      final updates = {
        'refundStatus': status.name,
        if (status == RefundStatus.completed)
          'refundedAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection(_collectionName)
          .doc(returnId)
          .update(updates);
    } catch (e) {
      throw ReturnServiceException('Failed to update refund status: $e');
    }
  }

  /// Approve a return request (admin operation)
  Future<void> approveReturn(String returnId, {String? trackingNumber}) async {
    try {
      await updateReturnStatus(
        returnId: returnId,
        status: ReturnStatus.approved,
        trackingNumber: trackingNumber,
      );
    } catch (e) {
      throw ReturnServiceException('Failed to approve return: $e');
    }
  }

  /// Reject a return request (admin operation)
  Future<void> rejectReturn(String returnId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(returnId)
          .update({'returnStatus': ReturnStatus.rejected.name});
    } catch (e) {
      throw ReturnServiceException('Failed to reject return: $e');
    }
  }

  /// Process refund (admin operation)
  Future<void> processRefund(String returnId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(returnId)
          .update({
        'refundStatus': RefundStatus.completed.name,
        'refundedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ReturnServiceException('Failed to process refund: $e');
    }
  }

  /// Check if product can be returned (within 30 days)
  bool canReturnProduct(DateTime orderDate) {
    final daysSinceOrder = DateTime.now().difference(orderDate).inDays;
    return daysSinceOrder <= 30;
  }

  /// Get return policy
  String getReturnPolicy() {
    return '''
    Return Policy
    
    • Returns are accepted within 30 days of purchase
    • Item must be in original condition with all packaging
    • Refunds are processed within 5-7 business days
    • Shipping cost is non-refundable unless item is defective
    • Damaged items require photo evidence
    • For assistance, contact our support team
    ''';
  }
}

class ReturnServiceException implements Exception {
  final String message;
  ReturnServiceException(this.message);

  @override
  String toString() => message;
}
