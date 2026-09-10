import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/mocks.dart';

enum ProductsByCategoryViewState { loading, success, error }

// class LoginController extends ChangeNotifier {
//   final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//   final int _caracterMinimoSenha = 6;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController senhaController = TextEditingController();
//   final GlobalKey<FormState> key = GlobalKey<FormState>();

class ProductsByCategoryController extends ChangeNotifier {
  List<Products> categoryProducts = [];

  String query = '';

  ProductsByCategoryViewState state = ProductsByCategoryViewState.loading;

  void changeState(ProductsByCategoryViewState newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> getProductsByCategory(String category) async {
    changeState(ProductsByCategoryViewState.loading);
    await Future.delayed(const Duration(seconds: 3)); // simula a API

    try {
      categoryProducts = productsJson
          .map((item) => Products.fromJson(item)) // desserializa
          .where((product) => product.category == category)
          .toList();

      changeState(ProductsByCategoryViewState.success);
    } catch (e) {
      changeState(ProductsByCategoryViewState.error);
    }
  }

  Future<void> searchProducts(String query) async {
    changeState(ProductsByCategoryViewState.loading);
    await Future.delayed(const Duration(seconds: 1)); // simula a API

    try {
      categoryProducts = productsJson
          .map((item) => Products.fromJson(item)) // desserializa
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.brand.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      changeState(ProductsByCategoryViewState.success);
    } catch (e) {
      changeState(ProductsByCategoryViewState.error);
    }
  }

  void search(String query) {
    query = query;
    notifyListeners();
  }
}
