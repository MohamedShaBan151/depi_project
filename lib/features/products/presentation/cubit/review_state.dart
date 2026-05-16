part of 'review_cubit.dart';

/// Review state definitions
sealed class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  final RatingSummary ratingSummary;

  const ReviewsLoaded({
    required this.reviews,
    required this.ratingSummary,
  });

  int get reviewCount => reviews.length;

  double get averageRating => ratingSummary.averageRating;

  int get totalReviews => ratingSummary.totalReviews;

  @override
  List<Object?> get props => [reviews, ratingSummary];
}

class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

class ReviewSubmitted extends ReviewState {
  const ReviewSubmitted();
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
