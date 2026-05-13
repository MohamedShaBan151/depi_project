import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/product_service.dart';
import '../../domain/entities/product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  static const List<String> categories = [
    'All', 'Electronics', 'Fashion', 'Grocery', 'Toys',
    'Home', 'Beauty', 'Sports', 'Books', 'Automotive', 'Health', 'Baby',
  ];
  final ProductService _service;
  List<Product> _all = [];
  StreamSubscription<dynamic>? _subscription;

  String _selectedCategory = 'All';
  String _sortBy = '';
  String _searchQuery = '';

  ProductCubit(this._service) : super(ProductInitial());

  void loadProducts() {
    _subscription?.cancel();
    emit(ProductLoading());
    _subscription = _service.watchProducts().listen(
      (models) {
        _all = models.map((m) => m.toEntity()).toList();
        _applyFilters();
      },
      onError: (Object e) => emit(ProductError(e.toString())),
    );
  }

  void filterByCategory(String cat) {
    _selectedCategory = cat;
    _applyFilters();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void sortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
  }

  void advancedSearch({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
  }) {
    _searchQuery = query;
    if (category != null) _selectedCategory = category;
    if (sortBy != null) _sortBy = sortBy;

    emit(ProductLoading());
    _service.searchProducts(
      query: query,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      sortBy: sortBy ?? _sortBy,
    ).then((models) {
      _all = models.map((m) => m.toEntity()).toList();
      emit(ProductLoaded(List.of(_all)));
    }).catchError((e) {
      emit(ProductError(e.toString()));
    });
  }

  void _applyFilters() {
    var filtered = List<Product>.from(_all);

    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    switch (_sortBy) {
      case 'price_asc':
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
      case 'popular':
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    emit(ProductLoaded(filtered));
  }

  String get selectedCategory => _selectedCategory;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  void loadAll() {
    _selectedCategory = 'All';
    _sortBy = '';
    _searchQuery = '';
    loadProducts();
  }
}
