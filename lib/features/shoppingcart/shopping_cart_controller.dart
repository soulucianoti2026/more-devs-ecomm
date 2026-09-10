import 'package:flutter/material.dart';

class ShoppingCartController extends ChangeNotifier {
  List<String> cartItems = [];

  void addToCart(String productId) {
    cartItems.add(productId);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    cartItems.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
}
