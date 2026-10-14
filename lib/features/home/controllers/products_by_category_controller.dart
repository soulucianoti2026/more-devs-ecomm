import 'dart:async';
import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

enum ProductsByCategoryViewState { loading, success, error }

class ProductsByCategoryController extends ChangeNotifier {
  ProductsByCategoryController(this.api);
  final StoreService api;
  List<Products> categoryProducts = [];
  List<String> brands = [];
  String currentCategory = '';
  String query = '';
  String? brand;
  String? error;
  int _version = 0;
  Timer? _debounce;
  ProductsByCategoryViewState state = ProductsByCategoryViewState.loading;

  Future<void> getProductsByCategory(String categoryId) async {
    _debounce?.cancel();
    currentCategory = categoryId;
    query = '';
    brand = null;
    brands = [];
    final version = ++_version;
    state = ProductsByCategoryViewState.loading;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        api.getProducts(categoryId: categoryId),
        api.getBrands(categoryId),
      ]);
      if (version != _version) return;
      categoryProducts = results[0] as List<Products>;
      brands = results[1] as List<String>;
      error = null;
      state = ProductsByCategoryViewState.success;
    } catch (e) {
      if (version != _version) return;
      error = e.toString();
      state = ProductsByCategoryViewState.error;
    }
    notifyListeners();
  }

  void searchProducts(String input) {
    query = input.trim();
    _debounce?.cancel();
    final version = ++_version;
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(version),
    );
  }

  void filterBrand(String? value) {
    brand = value;
    _debounce?.cancel();
    _search(++_version);
  }

  Future<void> retry() => _search(++_version);

  Future<void> _search(int version) async {
    state = ProductsByCategoryViewState.loading;
    notifyListeners();
    try {
      final products = await api.getProducts(
        categoryId: currentCategory,
        search: query,
        brand: brand,
      );
      if (version != _version) return;
      categoryProducts = products;
      error = null;
      state = ProductsByCategoryViewState.success;
    } catch (e) {
      if (version != _version) return;
      error = e.toString();
      state = ProductsByCategoryViewState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    ++_version;
    _debounce?.cancel();
    super.dispose();
  }
}
