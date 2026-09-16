import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';

class ShoppingCartController extends ChangeNotifier {
  final List<Map<String, dynamic>> cartItems = [];

  int get totalItems {
    return cartItems.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] as int?) ?? 0),
    );
  }

  int getProductQuantity(String productName) {
    final item = cartItems.firstWhere(
      (element) => element['name'] == productName,
      orElse: () => {},
    );

    if (item.isEmpty) {
      return 0;
    }

    return (item['quantity'] as int?) ?? 0;
  }

  void addToCart(Products product) {
    final item = {
      'brand': product.brand,
      'name': product.name,
      'imageUrl': product.imageUrl,
      'price': product.price,
      'category': product.category,
      'quantity': 1,
    };

    final existingIndex = cartItems.indexWhere(
      (element) => element['name'] == product.name,
    );

    if (existingIndex >= 0) {
      final currentQuantity = cartItems[existingIndex]['quantity'] as int;
      cartItems[existingIndex]['quantity'] = currentQuantity + 1;
    } else {
      cartItems.add(item);
    }

    notifyListeners();
  }

  void decrementFromCart(String productName) {
    final existingIndex = cartItems.indexWhere(
      (element) => element['name'] == productName,
    );

    if (existingIndex < 0) {
      return;
    }

    final currentQuantity = cartItems[existingIndex]['quantity'] as int;

    if (currentQuantity <= 1) {
      cartItems.removeAt(existingIndex);
    } else {
      cartItems[existingIndex]['quantity'] = currentQuantity - 1;
    }

    notifyListeners();
  }

  void removeFromCart(String productName) {
    cartItems.removeWhere((item) => item['name'] == productName);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  String toJson() {
    return jsonEncode(cartItems);
  }

  void loadFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    cartItems
      ..clear()
      ..addAll(decoded.map((item) => Map<String, dynamic>.from(item as Map)));
    notifyListeners();
  }
}
