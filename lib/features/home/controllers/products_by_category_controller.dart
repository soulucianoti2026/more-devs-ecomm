import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/mocks/mocks.dart';

//TODO logica de confirmar para excluir o produto do carrinho, caso o usuario queira diminuir a quantidade do produto para 0.
enum ProductsByCategoryViewState { loading, success, error }

// class LoginController extends ChangeNotifier {
//   final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//   final int _caracterMinimoSenha = 6;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController senhaController = TextEditingController();
//   final GlobalKey<FormState> key = GlobalKey<FormState>();

class ProductsByCategoryController extends ChangeNotifier {
  List<Products> _allProductsByCategory = [];
  List<Products> categoryProducts = [];

  String currentCategory = '';
  String query = '';

  ProductsByCategoryViewState state = ProductsByCategoryViewState.loading;

  void changeState(ProductsByCategoryViewState newState) {
    state = newState;
    notifyListeners();
  }

  Future<void> getProductsByCategory(String category) async {
    currentCategory = category;
    query = '';
    changeState(ProductsByCategoryViewState.loading);
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      _allProductsByCategory = productsJson
          .map((item) => Products.fromJson(item))
          .where((product) => product.category == category)
          .toList();

      categoryProducts = List.from(_allProductsByCategory);
      changeState(ProductsByCategoryViewState.success);
    } catch (e) {
      changeState(ProductsByCategoryViewState.error);
    }
  }

  void searchProducts(String input) {
    final normalizedQuery = input.trim();
    query = normalizedQuery;

    if (currentCategory.isEmpty) {
      return;
    }

    try {
      if (normalizedQuery.isEmpty) {
        categoryProducts = List.from(_allProductsByCategory);
        notifyListeners();
        return;
      }

      final regex = RegExp(
        RegExp.escape(normalizedQuery),
        caseSensitive: false,
      );

      categoryProducts = _allProductsByCategory.where((product) {
        final searchValue = '${product.name} ${product.brand}';
        return regex.hasMatch(searchValue);
      }).toList();

      notifyListeners();
    } catch (e) {
      // silenciosamente trata o erro
    }
  }

  void search(String query) {
    query = query;
    notifyListeners();
  }
}
