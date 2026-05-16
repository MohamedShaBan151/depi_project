// lib/data/models/cart_item_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Maps /users/{userId}/cart/{cartItemId} — see Integration Plan §1.6
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_helpers.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String productTitle;
  final String imageUrl;
  final double price; // snapshot price at add-time
  final int quantity;
  final String? variantId;
  final String? variantColor;
  final String? variantSize;
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    this.variantId,
    this.variantColor,
    this.variantSize,
    required this.addedAt,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final attrs =
        data['variantAttributes'] as Map<String, dynamic>? ?? {};
    return CartItemModel(
      id: doc.id,
      productId: data['productId'] as String? ?? '',
      productTitle: data['productTitle'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] as int? ?? 1,
      variantId: data['variantId'] as String?,
      variantColor: attrs['color'] as String?,
      variantSize: attrs['size'] as String?,
      addedAt: tsToDate(data['addedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'productTitle': productTitle,
        'imageUrl': imageUrl,
        'price': price,
        'quantity': quantity,
        'variantId': variantId,
        'variantAttributes': {
          if (variantColor != null) 'color': variantColor,
          if (variantSize != null) 'size': variantSize,
        },
        'addedAt': FieldValue.serverTimestamp(),
      };

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        id: id,
        productId: productId,
        productTitle: productTitle,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity ?? this.quantity,
        variantId: variantId,
        variantColor: variantColor,
        variantSize: variantSize,
        addedAt: addedAt,
      );
}
