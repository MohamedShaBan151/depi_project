import '../domain/entities/product.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String imageUrl;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool isFeatured;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.imageUrl,
    this.originalPrice,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.isFeatured = false,
  });

  /// Firestore factory – only used with live Firebase.
  // factory ProductModel.fromDoc(DocumentSnapshot doc) { ... }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'category': category,
        'stock': stock,
        'imageUrl': imageUrl,
        'originalPrice': originalPrice,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFeatured': isFeatured,
      };

  Product toEntity() => Product(
        id: id,
        name: name,
        price: price,
        category: category,
        imageUrl: imageUrl,
        stock: stock,
        originalPrice: originalPrice,
        rating: rating,
        reviewCount: reviewCount,
        isFeatured: isFeatured,
      );
}
