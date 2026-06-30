class FirestoreProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final String imageUrl;
  final List<String> images;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final Map<String, dynamic> specifications;
  final DateTime createdAt;

  FirestoreProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.imageUrl,
    this.images = const [],
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.specifications = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory FirestoreProduct.fromJson(Map<String, dynamic> json) {
    return FirestoreProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stock: json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      specifications: json['specifications'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'imageUrl': imageUrl,
      'images': images,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FirestoreProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    String? imageUrl,
    List<String>? images,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
  }) {
    return FirestoreProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}