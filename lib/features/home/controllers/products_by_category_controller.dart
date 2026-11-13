import 'package:more_devs_do_zero/shared/app_analytics.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

enum ProductsByCategoryViewState { loading, success, error }

class ProductsByCategoryController extends ChangeNotifier {
  ProductsByCategoryController(this.api, {AppAnalytics? analytics})
    : analytics = analytics ?? AppAnalytics.instance;
  final AppAnalytics analytics;
  final StoreService api;
  List<Products> categoryProducts = [];
  List<String> brands = [];
  String currentCategory = '';
  String query = '';
  String itemListName = '';
  String? brand;
  String? error;
  int _version = 0;
  Timer? _debounce;
  ProductsByCategoryViewState state = ProductsByCategoryViewState.loading;

  Future<void> getProductsByCategory(
    String categoryId, {
    String? listName,
  }) async {
    itemListName = listName ?? categoryId;
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
      analytics.logViewItemList(itemListName);
      error = null;
      state = ProductsByCategoryViewState.success;
    } catch (e) {
      if (version != _version) return;
      analytics.logLoadError('products_by_category');
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
      const Duration(seconds: 1),
      () => _search(version, event: 'search'),
    );
  }

  void filterBrand(String? value) {
    brand = value;
    _debounce?.cancel();
    _search(++_version, event: 'filter_brand');
  }

  Future<void> retry() => _search(++_version);

  Future<void> _search(int version, {String? event}) async {
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
      if (event == 'search' && query.isNotEmpty) {
        analytics.logSearch(query, itemListName, products.length);
      } else if (event == 'filter_brand') {
        analytics.logFilterBrand(brand ?? '', itemListName, products.length);
      }
      error = null;
      state = ProductsByCategoryViewState.success;
    } catch (e) {
      if (version != _version) return;
      analytics.logLoadError('products_by_category');
      error = e.toString();
      state = ProductsByCategoryViewState.error;
    }
    notifyListeners();
  }

  void cancelPendingSearch() {
    ++_version;
    _debounce?.cancel();
  }

  @override
  void dispose() {
    ++_version;
    _debounce?.cancel();
    super.dispose();
  }
}
