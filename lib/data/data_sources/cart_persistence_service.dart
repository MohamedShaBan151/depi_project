// ─────────────────────────────────────────────────────────────────────────────
// cart_persistence_service.dart
//
// Persists cart items to SharedPreferences so the user's basket survives
// app restarts.  Serialisation is handled entirely here; the ShoppingCubit
// calls save/load without knowing about storage internals.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Thin storage façade for cart persistence.
///
/// Key used: `'noon_cart_v1'`  (versioned so a schema bump can clear stale data).
class CartPersistenceService {
  static const String _key = 'noon_cart_v1';

  final SharedPreferences _prefs;

  const CartPersistenceService(this._prefs);

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Loads persisted cart items.  Returns an empty list on first run or error.
  List<CartItem> loadCart() {
    try {
      final raw = _prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const [];

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => _cartItemFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupt data: silently discard → fresh cart.
      _prefs.remove(_key);
      return const [];
    }
  }

  /// Persists the current cart items.  Fire-and-forget (returns Future but
  /// callers can await if they need to sequence).
  Future<void> saveCart(List<CartItem> items) async {
    final encoded = jsonEncode(items.map(_cartItemToJson).toList());
    await _prefs.setString(_key, encoded);
  }

  /// Wipes the persisted cart (called on sign-out or after order placement).
  Future<void> clearCart() => _prefs.remove(_key);

  // ── Serialisation helpers ──────────────────────────────────────────────────

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
