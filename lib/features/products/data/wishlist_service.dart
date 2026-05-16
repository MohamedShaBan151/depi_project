import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/wishlist_model.dart';
import 'models/product_model.dart';

/// Service for managing user wishlists
class WishlistService {
  static const String _collectionName = 'wishlists';

  final FirebaseFirestore _firestore;

  WishlistService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user's wishlist
  Future<WishlistModel> getWishlist(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return WishlistModel(
          userId: userId,
          items: [],
          updatedAt: DateTime.now(),
        );
      }

      return WishlistModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw WishlistServiceException('Failed to get wishlist: $e');
    }
  }

  /// Stream user's wishlist for real-time updates
  Stream<WishlistModel> watchWishlist(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .doc(userId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          return WishlistModel(
            userId: userId,
            items: [],
            updatedAt: DateTime.now(),
          );
        }
        return WishlistModel.fromJson(doc.data() as Map<String, dynamic>);
      });
    } catch (e) {
      throw WishlistServiceException('Failed to watch wishlist: $e');
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist({
    required String userId,
    required ProductModel product,
  }) async {
    try {
      final wishlist = await getWishlist(userId);

      // Check if product already in wishlist
      if (wishlist.containsProduct(product.id)) {
        return;
      }

      final newItem = WishlistItemModel(
        productId: product.id,
        productName: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        addedAt: DateTime.now(),
      );

      final updatedItems = [...wishlist.items, newItem];

      await _firestore.collection(_collectionName).doc(userId).set({
        'userId': userId,
        'items': updatedItems.map((item) => item.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw WishlistServiceException('Failed to add to wishlist: $e');
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final wishlist = await getWishlist(userId);

      final updatedItems = wishlist.items
          .where((item) => item.productId != productId)
          .toList();

      await _firestore.collection(_collectionName).doc(userId).set({
        'userId': userId,
        'items': updatedItems.map((item) => item.toJson()).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw WishlistServiceException('Failed to remove from wishlist: $e');
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist({
    required String userId,
    required String productId,
  }) async {
    try {
      final wishlist = await getWishlist(userId);
      return wishlist.containsProduct(productId);
    } catch (e) {
      throw WishlistServiceException('Failed to check wishlist: $e');
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist(String userId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(userId)
          .set({
        'userId': userId,
        'items': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw WishlistServiceException('Failed to clear wishlist: $e');
    }
  }

  /// Move product from wishlist to cart (returns the wishlist item)
  Future<WishlistItemModel?> moveToCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final wishlist = await getWishlist(userId);
      final item = wishlist.items
          .firstWhere((item) => item.productId == productId,
              orElse: () => WishlistItemModel(
                productId: productId,
                productName: '',
                price: 0,
                imageUrl: '',
                addedAt: DateTime.now(),
              ));

      if (item.productName.isNotEmpty) {
        await removeFromWishlist(userId: userId, productId: productId);
        return item;
      }

      return null;
    } catch (e) {
      throw WishlistServiceException('Failed to move to cart: $e');
    }
  }
}

class WishlistServiceException implements Exception {
  final String message;
  WishlistServiceException(this.message);

  @override
  String toString() => message;
}
