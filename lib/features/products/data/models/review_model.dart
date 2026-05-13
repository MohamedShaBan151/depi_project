class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}

class ReviewService {
  static final Map<String, List<ProductReview>> _reviews = {};

  static List<ProductReview> getReviews(String productId) {
    return _reviews[productId] ?? [];
  }

  static double getAverageRating(String productId) {
    final reviews = _reviews[productId] ?? [];
    if (reviews.isEmpty) return 0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  static void addReview(ProductReview review) {
    _reviews.putIfAbsent(review.productId, () => []);
    _reviews[review.productId]!.insert(0, review);
  }
}
