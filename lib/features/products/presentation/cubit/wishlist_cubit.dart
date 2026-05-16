import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/wishlist_model.dart';
import '../../data/wishlist_service.dart';

part 'wishlist_state.dart';

/// Cubit for managing wishlist state
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistService _wishlistService;
  final String _userId;

  WishlistCubit({
    required WishlistService wishlistService,
    required String userId,
  })  : _wishlistService = wishlistService,
        _userId = userId,
        super(const WishlistInitial());

  /// Load user's wishlist
  Future<void> loadWishlist() async {
    try {
      emit(const WishlistLoading());
      final wishlist = await _wishlistService.getWishlist(_userId);
      emit(WishlistLoaded(wishlist));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Watch wishlist for real-time updates
  void watchWishlist() {
    try {
      emit(const WishlistLoading());
      final stream = _wishlistService.watchWishlist(_userId);
      
      stream.listen(
        (wishlist) {
          emit(WishlistLoaded(wishlist));
        },
        onError: (error) {
          emit(WishlistError(error.toString()));
        },
      );
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(dynamic product) async {
    try {
      // Extract product model from either ProductModel or dynamic type
      await _wishlistService.addToWishlist(
        userId: _userId,
        product: product,
      );
      await loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _wishlistService.removeFromWishlist(
        userId: _userId,
        productId: productId,
      );
      await loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      await _wishlistService.clearWishlist(_userId);
      await loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId) async {
    try {
      return await _wishlistService.isInWishlist(
        userId: _userId,
        productId: productId,
      );
    } catch (e) {
      return false;
    }
  }
}
