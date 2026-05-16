// lib/data/models/product_firestore_full.dart
// ─────────────────────────────────────────────────────────────────────────────
// Maps /product/{productId} + subcollections (inventory, reviews, variants)
// See Firestore Integration Plan §1.5
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helpers.dart';

// ── Product ───────────────────────────────────────────────────────────────────

class ProductFull {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? compareAtPrice;
  final String categoryId;
  final String categoryName;
  final String? brandId;
  final String? brandName;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String status; // active | draft | archived
  final String slug;
  final List<String> tags;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const ProductFull({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.compareAtPrice,
    required this.categoryId,
    required this.categoryName,
    this.brandId,
    this.brandName,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = 'active',
    required this.slug,
    this.tags = const [],
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((compareAtPrice! - price) / compareAtPrice!) * 100).round();
  }

  String get primaryImage => images.isNotEmpty ? images.first : '';

  factory ProductFull.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductFull(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (data['compareAtPrice'] as num?)?.toDouble(),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      brandId: data['brandId'] as String?,
      brandName: data['brandName'] as String?,
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      status: data['status'] as String? ?? 'active',
      slug: data['slug'] as String? ?? '',
      tags: (data['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: tsToDate(data['createdAt']),
      updatedAt: tsToDate(data['updatedAt']),
      deletedAt: tsToDateNullable(data['deletedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'description': description,
        'price': price,
        'compareAtPrice': compareAtPrice,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'brandId': brandId,
        'brandName': brandName,
        'images': images,
        'rating': rating,
        'reviewCount': reviewCount,
        'status': status,
        'slug': slug,
        'tags': tags,
        'isDeleted': isDeleted,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

// ── Inventory subcollection ───────────────────────────────────────────────────

class ProductInventory {
  final String id;
  final int quantityAvailable;
  final int quantityReserved;
  final int lowStockThreshold;
  final bool trackInventory;
  final DateTime updatedAt;

  const ProductInventory({
    required this.id,
    required this.quantityAvailable,
    this.quantityReserved = 0,
    this.lowStockThreshold = 5,
    this.trackInventory = true,
    required this.updatedAt,
  });

  bool get isLowStock =>
      trackInventory && quantityAvailable <= lowStockThreshold;

  bool get isInStock =>
      !trackInventory || quantityAvailable > quantityReserved;

  factory ProductInventory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductInventory(
      id: doc.id,
      quantityAvailable: data['quantityAvailable'] as int? ?? 0,
      quantityReserved: data['quantityReserved'] as int? ?? 0,
      lowStockThreshold: data['lowStockThreshold'] as int? ?? 5,
      trackInventory: data['trackInventory'] as bool? ?? true,
      updatedAt: tsToDate(data['updatedAt']),
    );
  }
}

// ── Review subcollection ──────────────────────────────────────────────────────

class ProductReview {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final int rating; // 1–5
  final String title;
  final String body;
  final List<String> images;
  final bool isVerifiedPurchase;
  final String? orderId;
  final int helpfulCount;
  final bool isDeleted;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.rating,
    required this.title,
    required this.body,
    this.images = const [],
    this.isVerifiedPurchase = false,
    this.orderId,
    this.helpfulCount = 0,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory ProductReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductReview(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userDisplayName: data['userDisplayName'] as String? ?? '',
      userAvatarUrl: data['userAvatarUrl'] as String?,
      rating: data['rating'] as int? ?? 5,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      images: (data['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerifiedPurchase: data['isVerifiedPurchase'] as bool? ?? false,
      orderId: data['orderId'] as String?,
      helpfulCount: data['helpfulCount'] as int? ?? 0,
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: tsToDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'userDisplayName': userDisplayName,
        'userAvatarUrl': userAvatarUrl,
        'rating': rating,
        'title': title,
        'body': body,
        'images': images,
        'isVerifiedPurchase': isVerifiedPurchase,
        'orderId': orderId,
        'helpfulCount': helpfulCount,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ── Variant subcollection ─────────────────────────────────────────────────────

class ProductVariant {
  final String id;
  final String sku;
  final double price;
  final String? imageUrl;
  final String? color;
  final String? size;

  const ProductVariant({
    required this.id,
    required this.sku,
    required this.price,
    this.imageUrl,
    this.color,
    this.size,
  });

  factory ProductVariant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final attrs = data['attributes'] as Map<String, dynamic>? ?? {};
    return ProductVariant(
      id: doc.id,
      sku: data['sku'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String?,
      color: attrs['color'] as String?,
      size: attrs['size'] as String?,
    );
  }
}
