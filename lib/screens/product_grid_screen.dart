// ─────────────────────────────────────────────────────────────────────────────
// product_grid_screen.dart  –  Home screen using Sliver layout
//
// Key Sliver pieces:
//   SliverAppBar   – collapsible yellow header with search
//   SliverToBoxAdapter – horizontal category chips
//   SliverPadding + SliverGrid – 2-column product grid
//
// Hero tag format: 'product-${product.id}'
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/saudi_theme.dart';
import '../cubits/shopping_cubit.dart';
import '../data/models/models.dart';
import 'product_details_screen.dart';

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All', 'Electronics', 'Fashion', 'Grocery', 'Toys',
  ];

  List<Product> get _filtered {
    if (_selectedCategory == 'All') return MockData.products;
    return MockData.products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Collapsible yellow AppBar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Text(
                  'ن',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: const Text(
              'noon  نون',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              // Cart icon with badge
              BlocBuilder<ShoppingCubit, ShoppingState>(
                builder: (context, state) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.darkGreen,
                          size: 26,
                        ),
                        onPressed: () {},
                      ),
                      if (state.cartCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 17,
                            height: 17,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${state.cartCount}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SafeArea(
                  top: false,
                  child: _SearchBar(),
                ),
              ),
            ),
          ),

          // ── Category chip row ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat      = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.secondary
                            : AppColors.lightYellow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.secondary
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.darkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── 2-column product grid ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(product: products[index]),
                childCount: products.length,
              ),
            ),
          ),

          // ── Bottom padding so FAB doesn't overlap last row ───────────────
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search Noon…',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ProductDetailsScreen(productId: product.id),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.divider),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      height: 120,
                      color: AppColors.lightYellow,
                      child: Center(
                        child: _CategoryIcon(category: product.category),
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${product.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Wishlist toggle
                Positioned(
                  top: 6,
                  right: 6,
                  child: BlocBuilder<ShoppingCubit, ShoppingState>(
                    builder: (ctx, state) {
                      final wishlisted = state.isWishlisted(product.id);
                      return GestureDetector(
                        onTap: () =>
                            ctx.read<ShoppingCubit>().toggleWishlist(product),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            wishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: wishlisted
                                ? AppColors.error
                                : Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StarRow(rating: product.rating),
                    const Spacer(),
                    // Price + add-to-cart
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  'SAR ${product.originalPrice!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'SAR ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add button
                        BlocBuilder<ShoppingCubit, ShoppingState>(
                          builder: (ctx, state) {
                            final inCart = state.isInCart(product.id);
                            return GestureDetector(
                              onTap: () =>
                                  ctx.read<ShoppingCubit>().addToCart(product),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: inCart
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  inCart ? Icons.check : Icons.add,
                                  color: inCart
                                      ? AppColors.darkGreen
                                      : Colors.white,
                                  size: 17,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half   = !filled && i < rating && rating - i >= 0.5;
          return Icon(
            half
                ? Icons.star_half
                : filled
                    ? Icons.star
                    : Icons.star_border,
            size: 11,
            color: const Color(0xFFFFCC00),
          );
        }),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

// ── Category icon placeholder ─────────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  final String category;
  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (category.toLowerCase()) {
      'electronics' => (Icons.devices_other,         const Color(0xFF1565C0)),
      'fashion'     => (Icons.checkroom,              const Color(0xFF880E4F)),
      'grocery'     => (Icons.local_grocery_store,    const Color(0xFF2E7D32)),
      'toys'        => (Icons.toys,                   const Color(0xFFE65100)),
      _             => (Icons.inventory_2_outlined,   AppColors.secondary),
    };
    return Icon(icon, size: 52, color: color.withValues(alpha: 0.55));
  }
}
