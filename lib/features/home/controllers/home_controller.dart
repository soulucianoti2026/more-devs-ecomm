import 'package:flutter/widgets.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/mocks.dart';

enum CategoriesViewState { loading, sucess, error }

enum ProductsViewState { loading, sucess, error }

// List<BannerModel> listBanners = [
//     BannerModel(pathImage: banner1, id: "1"),
//     BannerModel(pathImage: banner2, id: "2"),
//     BannerModel(pathImage: banner3, id: "3"),
//     BannerModel(pathImage: banner4, id: "4"),
// ];

class HomeController extends ChangeNotifier {
  List<Category> categories = [];
  List<Products> products = [];

  CategoriesViewState categoriesViewState = CategoriesViewState.loading;

  void changeCategoriesState(CategoriesViewState state) {
    categoriesViewState = state;
    notifyListeners();
  }

  void changeProductsState(ProductsViewState state) {
    productsViewState = state;
    notifyListeners();
  }

  Future<void> getCategories() async {
    changeCategoriesState(CategoriesViewState.loading);
    await Future.delayed(Duration(seconds: 3));

    try {
      categories = categoriesJson.map((e) {
        return Category.fromJson(e);
      }).toList();
      changeCategoriesState(CategoriesViewState.sucess);
    } catch (e) {
      changeCategoriesState(CategoriesViewState.error);
    }
  }

  ProductsViewState productsViewState = ProductsViewState.loading;

  Future<void> getProducts() async {
    changeProductsState(ProductsViewState.loading);

    await Future.delayed(Duration(seconds: 3));

    try {
      products = productsJson.map((e) {
        return Products.fromJson(e);
      }).toList();
      changeProductsState(ProductsViewState.sucess);
    } catch (e) {
      changeProductsState(ProductsViewState.error);
    }
  }
}
