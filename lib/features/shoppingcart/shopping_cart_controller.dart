import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';

class CartProduct extends Products {
  int quantity;

  CartProduct({
    required super.brand,
    required super.name,
    required super.imageUrl,
    required super.price,
    required super.category,
    this.quantity = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'quantity': quantity,
    };
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      brand: json['brand'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class ShoppingCartController extends ChangeNotifier {
  final List<CartProduct> cartItems = [];

  int get totalItems {
    return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double getTotalPrice() {
    return cartItems.fold<double>(0, (sum, item) {
      final price = item.price;
      final quantity = item.quantity;
      return sum + (price * quantity);
    });
  }

  double getProductSubtotal(String productName) {
    final item = cartItems.firstWhere(
      (element) => element.name == productName,
      orElse: () => CartProduct(
        brand: '',
        name: '',
        imageUrl: '',
        price: 0,
        category: '',
      ),
    );

    final price = item.price;
    final quantity = item.quantity;

    return price.toDouble() * quantity;
  }

  int getProductQuantity(String productName) {
    final item = cartItems.firstWhere(
      (element) => element.name == productName,
      orElse: () => CartProduct(
        brand: '',
        name: '',
        imageUrl: '',
        price: 0,
        category: '',
      ),
    );

    return (item.quantity);
  }

  void addToCart(Products product) {
    final item = CartProduct(
      brand: product.brand,
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      category: product.category,
      quantity: 1,
    );

    final existingIndex = cartItems.indexWhere(
      (element) => element.name == product.name,
    );

    if (existingIndex >= 0) {
      cartItems[existingIndex] = cartItems[existingIndex];
      cartItems[existingIndex].quantity += 1;
    } else {
      cartItems.add(item);
    }

    notifyListeners();
  }

  void decrementFromCart(String productName) {
    final existingIndex = cartItems.indexWhere(
      (element) => element.name == productName,
    );

    if (existingIndex < 0) {
      return;
    }

    final currentQuantity = cartItems[existingIndex].quantity;

    if (currentQuantity <= 1) {
      cartItems.removeAt(existingIndex);
    } else {
      cartItems[existingIndex] = cartItems[existingIndex];
      cartItems[existingIndex].quantity -= 1;
    }

    notifyListeners();
  }

  void removeFromCart(String productName) {
    cartItems.removeWhere((item) => item.name == productName);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  String toJson() {
    return jsonEncode(cartItems);
  }
}
