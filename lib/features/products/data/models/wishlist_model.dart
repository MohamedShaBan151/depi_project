import 'package:equatable/equatable.dart';

/// Wishlist item model
class WishlistItemModel extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final DateTime addedAt;

  const WishlistItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.addedAt,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      addedAt: json['addedAt'] is DateTime
          ? json['addedAt'] as DateTime
          : DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'imageUrl': imageUrl,
        'addedAt': addedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [productId, addedAt];
}

/// Wishlist model
class WishlistModel extends Equatable {
  final String userId;
  final List<WishlistItemModel> items;
  final DateTime updatedAt;

  const WishlistModel({
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  int get itemCount => items.length;

  bool containsProduct(String productId) =>
      items.any((item) => item.productId == productId);

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return WishlistModel(
      userId: json['userId'] as String,
      items: itemsList.map((item) => WishlistItemModel.fromJson(item)).toList(),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  WishlistModel copyWith({
    String? userId,
    List<WishlistItemModel>? items,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, items.length, updatedAt];
}
