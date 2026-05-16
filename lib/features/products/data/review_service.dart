import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/review_model.dart';

/// Service for managing product reviews
class ReviewService {
  static const String _collectionName = 'reviews';
  static const String _productsCollectionName = 'products';

  final FirebaseFirestore _firestore;

  ReviewService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a new review for a product
  Future<String> addReview({
    required String productId,
    required ReviewModel review,
  }) async {
    try {
      final docRef = _firestore.collection(_collectionName).doc();
      final reviewWithId = review.copyWith(id: docRef.id);

      await docRef.set(reviewWithId.toJson());

      // Update product's average rating
      await _updateProductRating(productId);

      return docRef.id;
    } catch (e) {
      throw ReviewServiceException('Failed to add review: $e');
    }
  }

  /// Get reviews for a specific product
  Future<List<ReviewModel>> getProductReviews({
    required String productId,
    int limit = 10,
    String? sortBy = 'recent', // recent, helpful, rating
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('productId', isEqualTo: productId);

      // Apply sorting
      switch (sortBy) {
        case 'helpful':
          query = query.orderBy('helpfulCount', descending: true);
        case 'rating':
          query = query.orderBy('rating', descending: true);
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ReviewServiceException('Failed to get reviews: $e');
    }
  }

  /// Stream reviews for real-time updates
  Stream<List<ReviewModel>> watchProductReviews({
    required String productId,
    int limit = 10,
  }) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  ReviewModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw ReviewServiceException('Failed to watch reviews: $e');
    }
  }

  /// Get rating summary for a product
  Future<RatingSummary> getProductRatingSummary(String productId) async {
    try {
      final docs = await _firestore
          .collection(_collectionName)
          .where('productId', isEqualTo: productId)
          .get();

      if (docs.docs.isEmpty) {
        return RatingSummary.empty();
      }

      double sum = 0;
      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in docs.docs) {
        final review =
            ReviewModel.fromJson(doc.data());
        sum += review.rating;
        distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
      }

      final average = sum / docs.docs.length;

      return RatingSummary(
        averageRating: double.parse(average.toStringAsFixed(1)),
        totalReviews: docs.docs.length,
        ratingDistribution: distribution,
      );
    } catch (e) {
      throw ReviewServiceException('Failed to get rating summary: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String productId,
  }) async {
    try {
      await _firestore.collection(_collectionName).doc(reviewId).delete();

      // Update product rating
      await _updateProductRating(productId);
    } catch (e) {
      throw ReviewServiceException('Failed to delete review: $e');
    }
  }

  /// Mark review as helpful
  Future<void> markAsHelpful(String reviewId) async {
    try {
      await _firestore.collection(_collectionName).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw ReviewServiceException('Failed to mark review as helpful: $e');
    }
  }

  /// Update product's average rating based on reviews
  Future<void> _updateProductRating(String productId) async {
    try {
      final summary = await getProductRatingSummary(productId);

      await _firestore
          .collection(_productsCollectionName)
          .doc(productId)
          .update({
        'rating': summary.averageRating,
        'reviewCount': summary.totalReviews,
      });
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Warning: Failed to update product rating: $e');
    }
  }

  /// Check if user has already reviewed product
  Future<bool> hasUserReviewedProduct({
    required String productId,
    required String userId,
  }) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw ReviewServiceException('Failed to check review status: $e');
    }
  }

  /// Get user's review for a product
  Future<ReviewModel?> getUserReviewForProduct({
    required String productId,
    required String userId,
  }) async {
    try {
      final query = await _firestore
          .collection(_collectionName)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return ReviewModel.fromJson(
          query.docs.first.data());
    } catch (e) {
      throw ReviewServiceException('Failed to get user review: $e');
    }
  }
}

class ReviewServiceException implements Exception {
  final String message;
  ReviewServiceException(this.message);

  @override
  String toString() => message;
}
