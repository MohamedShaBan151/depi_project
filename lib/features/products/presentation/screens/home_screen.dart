import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../../cubits/shopping_cubit.dart';
import '../../../../data/models/models.dart' as models;
import '../../domain/entities/product.dart';

import '../../../../widgets/noon_bottom_nav.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

// ── Shell ─────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final String? userName; // من login/register

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
      _HomePage(userName: widget.userName), // ✅ FIX HERE
      const _SearchPage(),
      const _CartPage(),
      const _AccountPage(),
    ];

    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) {
          return NoonBottomNav(
            currentIndex: _currentIndex,
            cartBadge: state.cartCount > 0 ? state.cartCount : null,
            onTap: (i) => setState(() => _currentIndex = i),
          );
        },
      ),
    );
  }
}

// ── Home Page ────────────────────────────────────────────────────────────────

class _HomePage extends StatefulWidget {
  final String? userName;

  const _HomePage({this.userName});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Grocery',
    'Toys'
  ];

  void _addToCart(Product product) {
    context.read<ShoppingCubit>().addToCart(
      models.Product(
        id: product.id,
        name: product.name,
        category: product.category,
        price: product.price,
        imageUrl: product.imageUrl,
        stock: 0,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: AppColors.darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          _buildCategoryBar(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            widget.userName != null
                ? 'Welcome ${widget.userName}'
                : 'نون  ·  Noon',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 12),
          const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        ],
      ),
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Widget _buildCategoryBar() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat);
              context.read<ProductCubit>().filterByCategory(cat);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.darkGreen : AppColors.lightGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.darkGreen,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Widget _buildProductGrid() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        return switch (state) {
          ProductLoading() =>
          const Center(child: CircularProgressIndicator()),

          ProductError(:final message) =>
              Center(child: Text(message)),

          ProductLoaded(:final products) =>
              GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                ),
                itemCount: products.length,
                itemBuilder: (_, i) => Card(
                  child: Column(
                    children: [
                      Text(products[i].name),
                      Text('${products[i].price}'),
                      ElevatedButton(
                        onPressed: () => _addToCart(products[i]),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
              ),

          _ => const SizedBox(),
        };
      },
    );
  }
}

// ── Placeholder Pages ───────────────────────────────────────────────────────

class _SearchPage extends StatelessWidget {
  const _SearchPage();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Search'));
}

class _CartPage extends StatelessWidget {
  const _CartPage();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Cart'));
}

class _AccountPage extends StatelessWidget {
  const _AccountPage();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Account'));
}