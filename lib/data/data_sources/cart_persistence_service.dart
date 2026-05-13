import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class CartPersistenceService {
  static const String _cartKey = 'noon_cart_v1';
  static const String _wishlistKey = 'noon_wishlist_v1';

  final SharedPreferences _prefs;

  const CartPersistenceService(this._prefs);

  List<CartItem> loadCart() {
    try {
      final raw = _prefs.getString(_cartKey);
      if (raw == null || raw.isEmpty) return const [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => _cartItemFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_cartKey);
      return const [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    final encoded = jsonEncode(items.map(_cartItemToJson).toList());
    await _prefs.setString(_cartKey, encoded);
  }

  Future<void> clearCart() => _prefs.remove(_cartKey);

  List<Product> loadWishlist() {
    try {
      final raw = _prefs.getString(_wishlistKey);
      if (raw == null || raw.isEmpty) return const [];
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => _productFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_wishlistKey);
      return const [];
    }
  }

  Future<void> saveWishlist(List<Product> items) async {
    final encoded = jsonEncode(items.map(_productToJson).toList());
    await _prefs.setString(_wishlistKey, encoded);
  }

  Map<String, dynamic> _cartItemToJson(CartItem item) => {
        'quantity': item.quantity,
        'product': _productToJson(item.product),
      };

  CartItem _cartItemFromJson(Map<String, dynamic> json) => CartItem(
        quantity: (json['quantity'] as num).toInt(),
        product: _productFromJson(json['product'] as Map<String, dynamic>),
      );

  Map<String, dynamic> _productToJson(Product p) => {
        'id': p.id,
        'name': p.name,
        'category': p.category,
        'price': p.price,
        'originalPrice': p.originalPrice,
        'rating': p.rating,
        'reviewCount': p.reviewCount,
        'stock': p.stock,
        'imageUrl': p.imageUrl,
        'isFeatured': p.isFeatured,
      };

  Product _productFromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: json['originalPrice'] != null
            ? (json['originalPrice'] as num).toDouble()
            : null,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: (json['reviewCount'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
        imageUrl: json['imageUrl'] as String? ?? '',
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}
