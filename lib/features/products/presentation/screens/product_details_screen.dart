import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../../cubits/shopping_cubit.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  Product? _product;

  @override
  void initState() {
    super.initState();
    _findProduct();
  }

  void _findProduct() {
    final state = context.read<ProductCubit>().state;
    if (state is ProductLoaded) {
      final match = state.products.where((p) => p.id == widget.productId).toList();
      if (match.isNotEmpty) {
        _product = match.first;
      }
    }
  }

  void _addToCart(Product product) {
    for (int i = 0; i < _quantity; i++) {
      context.read<ShoppingCubit>().addToCartFromDomain(product);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity × ${product.name} added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _toggleWishlist(Product product) {
    context.read<ShoppingCubit>().toggleWishlistFromDomain(product);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wishlist updated'), backgroundColor: AppColors.darkGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, foregroundColor: AppColors.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (state is ProductLoaded) {
              final match = state.products.where((p) => p.id == widget.productId).toList();
              if (match.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _product = match.first);
                });
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    final product = _product!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(product),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildProductInfo(product),
                _buildQuantitySelector(),
                _buildDeliveryInfo(),
                _buildSellerInfo(product),
                _buildReviewsSection(product),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(product),
    );
  }

  Widget _buildAppBar(Product product) {
    return SliverAppBar(
      backgroundColor: Colors.white, foregroundColor: AppColors.ink,
      elevation: 0, pinned: true, expandedHeight: 56,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
          ),
          child: const Icon(Icons.arrow_back),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        BlocBuilder<ShoppingCubit, ShoppingState>(
          builder: (context, state) {
            final isWishlisted = state.isWishlisted(widget.productId);
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                ),
                child: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.grey),
              ),
              onPressed: () => _toggleWishlist(product),
            );
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: const Icon(Icons.share_outlined),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageGallery() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 300, width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightGold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.inventory_2_outlined, size: 100,
                color: AppColors.darkGreen.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final isSelected = index == _selectedImageIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedImageIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 60 : 50, height: isSelected ? 60 : 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightGold.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.darkGreen : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkGreen, borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Featured', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: 12),
          ],
          Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(children: List.generate(5, (i) {
                final filled = i < product.rating.floor();
                final half = !filled && i < product.rating && product.rating - i >= 0.5;
                return Icon(half ? Icons.star_half : filled ? Icons.star : Icons.star_border, size: 18, color: AppColors.gold);
              })),
              const SizedBox(width: 8),
              Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 4),
              Text('(${product.reviewCount} reviews)', style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('ر.س${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
              if (product.hasDiscount) ...[
                const SizedBox(width: 12),
                Text('ر.س${product.originalPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                  child: Text('-${product.discountPercent}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الكمية', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(children: [
            GestureDetector(
              onTap: () { if (_quantity > 1) setState(() => _quantity--); },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.remove, size: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: () => setState(() => _quantity++),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
            const Spacer(),
          ]),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التوصيل', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 12),
          Row(children: [Icon(Icons.local_shipping, size: 18, color: AppColors.darkGreen), SizedBox(width: 8), Text('Free delivery on orders over 200 SAR')]),
          SizedBox(height: 8),
          Row(children: [Icon(Icons.assignment_return, size: 18, color: AppColors.darkGreen), SizedBox(width: 8), Text('Free 14-day returns')]),
          SizedBox(height: 8),
          Row(children: [Icon(Icons.schedule, size: 18, color: AppColors.darkGreen), SizedBox(width: 8), Text('Delivery in 2-4 business days')]),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(Product product) {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('البائع', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.darkGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.store, color: AppColors.darkGreen),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Noon Saudi Arabia', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('100% authentic products', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Product product) {
    return Container(
      color: Colors.white, margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('التقييمات', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          TextButton(onPressed: () => _showAddReviewDialog(product), child: const Text('Write a Review')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Text(product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: List.generate(5, (i) => Icon(
                i < product.rating.floor() ? Icons.star : Icons.star_border, size: 16, color: AppColors.gold))),
            Text('${product.reviewCount} reviews', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 16),
        const Text('No reviews yet. Be the first to review!', style: TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }

  void _showAddReviewDialog(Product product) {
    final commentController = TextEditingController();
    double rating = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Write a Review'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Rating'),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
              final starRating = i + 1;
              return IconButton(
                icon: Icon(starRating <= rating ? Icons.star : Icons.star_border,
                    color: AppColors.gold, size: 36),
                onPressed: () => setDialogState(() => rating = starRating.toDouble()),
              );
            })),
            const SizedBox(height: 16),
            TextField(
              controller: commentController, maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Your review', hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review submitted! Thank you.'), backgroundColor: AppColors.success),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(children: [
          Expanded(
            child: BlocBuilder<ShoppingCubit, ShoppingState>(
              builder: (context, state) {
                final isWishlisted = state.isWishlisted(widget.productId);
                return OutlinedButton.icon(
                  onPressed: () => _toggleWishlist(product),
                  icon: Icon(isWishlisted ? Icons.favorite : Icons.favorite_border,
                      color: isWishlisted ? Colors.red : null),
                  label: const Text('Wishlist'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen, padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('أضف للسلة - Add to Cart', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}
