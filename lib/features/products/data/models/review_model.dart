import 'package:equatable/equatable.dart';

/// Review rating enum for type safety
enum ReviewRating { 
  oneStar(1), 
  twoStars(2), 
  threeStars(3), 
  fourStars(4), 
  fiveStars(5);

  final int value;
  const ReviewRating(this.value);
}

/// Product review model
class ReviewModel extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int rating; // 1-5
  final String title;
  final String comment;
  final List<String> imageUrls; // Review images
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.title,
    required this.comment,
    this.imageUrls = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String? ?? '',
      rating: json['rating'] as int,
      title: json['title'] as String,
      comment: json['comment'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'title': title,
        'comment': comment,
        'imageUrls': imageUrls,
        'isVerifiedPurchase': isVerifiedPurchase,
        'helpfulCount': helpfulCount,
        'createdAt': createdAt.toIso8601String(),
      };

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? title,
    String? comment,
    List<String>? imageUrls,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        rating,
        createdAt,
      ];
}

/// Product rating summary
class RatingSummary extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating: count

  const RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory RatingSummary.empty() {
    return const RatingSummary(
      averageRating: 0.0,
      totalReviews: 0,
      ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    );
  }

  int getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0;
    return ((ratingDistribution[rating] ?? 0) / totalReviews * 100).round();
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingDistribution];
}
