import 'package:flutter/widgets.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

enum CategoriesViewState { loading, sucess, error }

enum ProductsViewState { loading, sucess, error }

class HomeController extends ChangeNotifier {
  HomeController(this.api);
  final StoreService api;
  List<Category> categories = [];
  List<Products> products = [];
  CategoriesViewState categoriesViewState = CategoriesViewState.loading;
  ProductsViewState productsViewState = ProductsViewState.loading;

  Future<void> getCategories() async {
    categoriesViewState = CategoriesViewState.loading;
    notifyListeners();
    try {
      categories = await api.getCategories();
      categoriesViewState = CategoriesViewState.sucess;
    } catch (_) {
      categoriesViewState = CategoriesViewState.error;
    }
    notifyListeners();
  }

  Future<void> getProducts() async {
    productsViewState = ProductsViewState.loading;
    notifyListeners();
    try {
      products = await api.getProducts();
      productsViewState = ProductsViewState.sucess;
    } catch (_) {
      productsViewState = ProductsViewState.error;
    }
    notifyListeners();
  }
}
