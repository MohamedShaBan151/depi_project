part of 'wishlist_cubit.dart';

/// Wishlist state definitions
sealed class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final WishlistModel wishlist;

  const WishlistLoaded(this.wishlist);

  int get itemCount => wishlist.itemCount;

  bool containsProduct(String productId) => wishlist.containsProduct(productId);

  @override
  List<Object?> get props => [wishlist];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}
