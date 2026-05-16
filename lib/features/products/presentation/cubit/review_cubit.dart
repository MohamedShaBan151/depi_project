import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/review_model.dart';
import '../../data/review_service.dart';

part 'review_state.dart';

/// Cubit for managing product reviews
class ReviewCubit extends Cubit<ReviewState> {
  final ReviewService _reviewService;

  ReviewCubit({required ReviewService reviewService})
      : _reviewService = reviewService,
        super(const ReviewInitial());

  /// Load reviews for a product
  Future<void> loadProductReviews({
    required String productId,
    int limit = 10,
    String sortBy = 'recent',
  }) async {
    try {
      emit(const ReviewLoading());
      final reviews = await _reviewService.getProductReviews(
        productId: productId,
        limit: limit,
        sortBy: sortBy,
      );
      final summary = await _reviewService.getProductRatingSummary(productId);
      emit(ReviewsLoaded(reviews: reviews, ratingSummary: summary));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  /// Watch product reviews for real-time updates
  void watchProductReviews(String productId, {int limit = 10}) {
    try {
      emit(const ReviewLoading());
      final stream = _reviewService.watchProductReviews(
        productId: productId,
        limit: limit,
      );

      stream.listen(
        (reviews) async {
          final summary =
              await _reviewService.getProductRatingSummary(productId);
          emit(ReviewsLoaded(reviews: reviews, ratingSummary: summary));
        },
        onError: (error) {
          emit(ReviewError(error.toString()));
        },
      );
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  /// Submit a new review
  Future<void> submitReview({required ReviewModel review}) async {
    try {
      emit(const ReviewSubmitting());
      await _reviewService.addReview(
        productId: review.productId,
        review: review,
      );
      emit(const ReviewSubmitted());
      // Reload reviews
      await loadProductReviews(productId: review.productId);
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  /// Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String productId,
  }) async {
    try {
      await _reviewService.deleteReview(
        reviewId: reviewId,
        productId: productId,
      );
      await loadProductReviews(productId: productId);
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  /// Mark review as helpful
  Future<void> markAsHelpful(String reviewId) async {
    try {
      await _reviewService.markAsHelpful(reviewId);
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  /// Check if user has reviewed product
  Future<bool> userHasReviewed({
    required String productId,
    required String userId,
  }) async {
    try {
      return await _reviewService.hasUserReviewedProduct(
        productId: productId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }
}
