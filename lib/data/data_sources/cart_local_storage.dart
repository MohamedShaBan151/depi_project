import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalStorage {
  static const String _cartKey = 'cart_items';
  final SharedPreferences _prefs;

  CartLocalStorage(this._prefs);

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final cartJson = _prefs.getString(_cartKey);
    if (cartJson == null) return [];
    final List<dynamic> decoded = jsonDecode(cartJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final cartJson = jsonEncode(items);
    await _prefs.setString(_cartKey, cartJson);
  }

  Future<void> clearCart() async {
    await _prefs.remove(_cartKey);
  }
}