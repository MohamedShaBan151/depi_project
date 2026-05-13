import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../../cubits/shopping_cubit.dart';
import '../../../../data/models/models.dart' as models;
import '../../data/product_service.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showFilters = false;

  String? _filterCategory;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _minRating = 0;
  String _sortBy = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<ProductCubit>().advancedSearch(
      query: _query,
      category: _filterCategory,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 10000 ? _priceRange.end : null,
      minRating: _minRating > 0 ? _minRating : null,
      sortBy: _sortBy.isNotEmpty ? _sortBy : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        title: const Text('بحث · Search'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, _showFilters ? 0 : 16),
            color: AppColors.darkGreen,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() => _query = value);
                _performSearch();
              },
            ),
          ),
          if (_showFilters) _buildFilters(),
          Expanded(
            child: _query.isEmpty && !_showFilters
                ? _SearchSuggestions(onCategoryTap: (cat) {
                    setState(() {
                      _filterCategory = cat;
                      _showFilters = true;
                      _performSearch();
                    });
                  })
                : BlocBuilder<ProductCubit, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is ProductLoaded) {
                        final products = state.products;
                        if (products.isEmpty) {
                          return _NoResults(query: _query);
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _SearchResultCard(product: products[index]);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filterCategory = null;
                    _priceRange = const RangeValues(0, 10000);
                    _minRating = 0;
                    _sortBy = '';
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', ...ProductService.categories.where((c) => c != 'All')].map((cat) {
                final selected = (_filterCategory ?? 'All') == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _filterCategory = cat == 'All' ? null : cat);
                      _performSearch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.darkGreen : AppColors.lightGold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(cat,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.darkGreen,
                            fontSize: 11, fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Price Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000,
            divisions: 20,
            labels: RangeLabels(
              'SAR ${_priceRange.start.toInt()}',
              'SAR ${_priceRange.end.toInt()}',
            ),
            onChanged: (v) {
              setState(() => _priceRange = v);
            },
            onChangeEnd: (_) => _performSearch(),
          ),
          const SizedBox(height: 8),
          const Text('Minimum Rating', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [0, 1, 2, 3, 4, 5].map((r) {
              final selected = _minRating == r;
              return GestureDetector(
                onTap: () {
                  setState(() => _minRating = r.toDouble());
                  _performSearch();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.darkGreen : AppColors.lightGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    r == 0 ? 'Any' : '$r+ ★',
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.darkGreen,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Text('Sort By', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ('', 'Relevance'),
              ('price_asc', 'Price ↑'),
              ('price_desc', 'Price ↓'),
              ('rating', 'Rating'),
              ('popular', 'Popular'),
            ].map((entry) {
              final val = entry.$1;
              final label = entry.$2;
              final selected = _sortBy == val;
              return GestureDetector(
                onTap: () {
                  setState(() => _sortBy = val);
                  _performSearch();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.darkGreen : AppColors.lightGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(label,
                      style: TextStyle(color: selected ? Colors.white : AppColors.darkGreen, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;

  const _SearchSuggestions({required this.onCategoryTap});

  final List<String> _suggestions = const [
    'Mobile phones', 'Laptops', 'Headphones', 'Smart watches',
    'Cameras', 'Gaming', 'Tablets', 'Accessories',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popular Searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _suggestions.map((s) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGold,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold),
                  ),
                  child: Text(s,
                      style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              ('Electronics', Icons.devices),
              ('Fashion', Icons.checkroom),
              ('Home', Icons.home),
              ('Beauty', Icons.face),
              ('Sports', Icons.sports),
              ('Toys', Icons.toys),
              ('Books', Icons.book),
              ('Grocery', Icons.restaurant),
            ].map((entry) {
              return _CategoryTile(
                icon: entry.$2,
                label: entry.$1,
                onTap: () => onCategoryTap(entry.$1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CategoryTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightGold.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.darkGreen),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off, size: 64, color: AppColors.darkGreen.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text('No results for "$query"',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Text('Try different keywords',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Product product;
  const _SearchResultCard({required this.product});

  void _addToCart(BuildContext context) {
    context.read<ShoppingCubit>().addToCart(
      models.Product(
        id: product.id, name: product.name, category: product.category,
        price: product.price, imageUrl: product.imageUrl, stock: product.stock,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart'), backgroundColor: AppColors.darkGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${product.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.lightGold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                Text('SAR ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkGreen)),
                const SizedBox(width: 8),
                Row(children: List.generate(5, (i) => Icon(
                    i < product.rating.floor() ? Icons.star : Icons.star_border,
                    size: 12, color: AppColors.gold))),
              ]),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: AppColors.darkGreen),
            onPressed: () => _addToCart(context),
          ),
        ]),
      ),
    );
  }
}
