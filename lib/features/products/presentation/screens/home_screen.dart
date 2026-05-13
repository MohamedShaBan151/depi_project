import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../../cubits/shopping_cubit.dart';
import '../../../../data/models/models.dart' as models;
import '../../domain/entities/product.dart';
import '../../../../widgets/noon_bottom_nav.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../data/product_service.dart';

import 'cart_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  const HomeScreen({super.key, this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _HomePage(userName: widget.userName),
      const SearchScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) => NoonBottomNav(
          currentIndex: _currentIndex,
          cartBadge: state.cartCount > 0 ? state.cartCount : null,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  final String? userName;
  const _HomePage({this.userName});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _selectedCategory = 'All';
  String _sortBy = '';

  void _addToCart(Product product) {
    context.read<ShoppingCubit>().addToCart(
      models.Product(
        id: product.id,
        name: product.name,
        category: product.category,
        price: product.price,
        originalPrice: product.originalPrice,
        rating: product.rating,
        reviewCount: product.reviewCount,
        stock: product.stock,
        imageUrl: product.imageUrl,
        isFeatured: product.isFeatured,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.name} added to cart'),
      backgroundColor: AppColors.darkGreen,
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.darkGreen,
            expandedHeight: 0,
            toolbarHeight: 56,
            title: Text(
              widget.userName != null
                  ? 'Welcome, ${widget.userName}!'
                  : 'نون  ·  Noon',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              BlocBuilder<ShoppingCubit, ShoppingState>(
                builder: (context, state) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    if (state.cartCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${state.cartCount}',
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGreen),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SliverToBoxAdapter(child: _HeroBannerCarousel()),
          const SliverToBoxAdapter(child: _PromoStrip()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _CountdownTimer(),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemCount: ProductService.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = ProductService.categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      context.read<ProductCubit>().filterByCategory(cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.darkGreen : AppColors.lightGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.darkGreen,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  const Text(
                    'Recommended for You',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy.isEmpty ? null : _sortBy,
                      hint: const Text('Sort', style: TextStyle(fontSize: 12)),
                      items: const [
                        DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'rating', child: Text('Top Rated', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'popular', child: Text('Most Popular', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'name', child: Text('Name A-Z', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) {
                        setState(() => _sortBy = v ?? '');
                        context.read<ProductCubit>().sortBy(v ?? '');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) => switch (state) {
              ProductLoading() => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator())),
              ProductError(:final message) => SliverFillRemaining(
                  child: Center(child: Text(message))),
              ProductLoaded(:final products) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _ProductCard(product: products[i], onAddToCart: _addToCart),
                      childCount: products.length,
                    ),
                  ),
                ),
              _ => const SliverToBoxAdapter(child: SizedBox.shrink()),
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onAddToCart;
  const _ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        product.originalPrice != null && product.originalPrice! > product.price;
    final discountPct = hasDiscount
        ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100)
            .round()
        : 0;

    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF5F5F5),
                    child: Icon(
                      _iconForCategory(product.category),
                      size: 56,
                      color: AppColors.darkGreen.withValues(alpha: 0.15),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discountPct%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (product.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '★ Top',
                          style: TextStyle(
                              color: AppColors.darkGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                              i < product.rating.floor()
                                  ? Icons.star
                                  : (i < product.rating
                                      ? Icons.star_half
                                      : Icons.star_border),
                              size: 12,
                              color: const Color(0xFFFFC107),
                            )),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SAR ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGreen),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 5),
                          Text(
                            '${product.originalPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed:
                            product.stock > 0 ? () => onAddToCart(product) : null,
                        child: Text(
                          product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
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

  IconData _iconForCategory(String category) {
    return switch (category) {
      'Electronics' => Icons.devices,
      'Fashion'     => Icons.checkroom,
      'Grocery'     => Icons.local_grocery_store,
      'Toys'        => Icons.toys,
      'Home'        => Icons.home,
      'Beauty'      => Icons.face,
      'Sports'      => Icons.sports,
      'Books'       => Icons.book,
      'Automotive'  => Icons.directions_car,
      'Health'      => Icons.health_and_safety,
      'Baby'        => Icons.child_care,
      _             => Icons.inventory_2_outlined,
    };
  }
}

class _HeroBannerCarousel extends StatefulWidget {
  const _HeroBannerCarousel();

  @override
  State<_HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<_HeroBannerCarousel> {
  static const _banners = [
    _Banner('Up to 50% Off Electronics', '🎧', Color(0xFF004D26)),
    _Banner('Flash Sale — Noon Yellow Friday', '⚡', Color(0xFF8B0000)),
    _Banner('Free Delivery on Groceries', '🛒', Color(0xFF006C35)),
  ];

  final _controller = PageController();
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _banners.length,
            itemBuilder: (context, i) => _BannerTile(banner: _banners[i]),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _current == i ? AppColors.primary : Colors.white60,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner {
  final String title;
  final String emoji;
  final Color color;
  const _Banner(this.title, this.emoji, this.color);
}

class _BannerTile extends StatelessWidget {
  final _Banner banner;
  const _BannerTile({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
          color: banner.color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                banner.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(banner.emoji, style: const TextStyle(fontSize: 52)),
          ),
        ],
      ),
    );
  }
}

class _PromoStrip extends StatelessWidget {
  const _PromoStrip();

  static const _perks = [
    ('Free Shipping', Icons.local_shipping_outlined),
    ('Easy Returns', Icons.assignment_return_outlined),
    ('Secure Pay', Icons.lock_outline),
    ('24/7 Support', Icons.headset_mic_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _perks
            .map((p) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.$2, size: 18, color: AppColors.darkGreen),
                    const SizedBox(height: 2),
                    Text(p.$1,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late DateTime _end;
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _end = DateTime.now().add(const Duration(hours: 5, minutes: 59, seconds: 59));
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = _end.difference(DateTime.now());
    if (mounted) setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          const Text('Deal ends in ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          _Seg(_pad(_remaining.inHours)),
          const _Sep(),
          _Seg(_pad(_remaining.inMinutes.remainder(60))),
          const _Sep(),
          _Seg(_pad(_remaining.inSeconds.remainder(60))),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String v;
  const _Seg(this.v);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.darkGreen, borderRadius: BorderRadius.circular(6)),
        child: Text(v,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      );
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(':', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
}
