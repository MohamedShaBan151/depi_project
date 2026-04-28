import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/product_service.dart';
import '../../domain/entities/product.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _service;
  List<Product> _all = [];
  StreamSubscription<dynamic>? _subscription;

  ProductCubit(this._service) : super(ProductInitial());

  void loadProducts() {
    _subscription?.cancel();
    emit(ProductLoading());
    _subscription = _service.watchProducts().listen(
      (models) {
        _all = models.map((m) => m.toEntity()).toList();
        emit(ProductLoaded(List.of(_all)));
      },
      onError: (Object e) => emit(ProductError(e.toString())),
    );
  }

  void filterByCategory(String cat) {
    final filtered = cat == 'All'
        ? List.of(_all)
        : _all.where((p) => p.category == cat).toList();
    emit(ProductLoaded(filtered));
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(ProductLoaded(List.of(_all)));
      return;
    }
    final filtered = _all
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    emit(ProductLoaded(filtered));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
