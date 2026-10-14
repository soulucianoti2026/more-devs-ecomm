import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

class CartProduct extends Products {
  final int quantity;
  final double subtotal;
  CartProduct({
    required Products product,
    required this.quantity,
    required this.subtotal,
  }) : super(
         id: product.id,
         categoryId: product.categoryId,
         description: product.description,
         brand: product.brand,
         name: product.name,
         imageUrl: product.imageUrl,
         price: product.price,
         category: product.category,
       );

  factory CartProduct.fromJson(Map<String, dynamic> json) => CartProduct(
    product: Products.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
    subtotal: (json['subtotal'] as num).toDouble(),
  );
}

class ShoppingCartController extends ChangeNotifier {
  ShoppingCartController(this.api) {
    _session = api.auth.session;
    api.auth.addListener(_sessionChanged);
  }
  final StoreService api;
  AuthSession? _session;
  List<CartProduct> cartItems = [];
  int totalItems = 0;
  double _total = 0;
  bool isLoading = false;
  String? error;
  int _version = 0;

  void _sessionChanged() {
    if (identical(_session, api.auth.session)) return;
    _session = api.auth.session;
    ++_version;
    cartItems = [];
    totalItems = 0;
    _total = 0;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  double getTotalPrice() => _total;
  double getProductSubtotal(String id) =>
      cartItems.where((e) => e.id == id).firstOrNull?.subtotal ?? 0;
  int getProductQuantity(String id) =>
      cartItems.where((e) => e.id == id).firstOrNull?.quantity ?? 0;

  void _apply(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .map((e) => CartProduct.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = json['itemCount'] as int;
    final total = (json['total'] as num).toDouble();
    cartItems = items;
    totalItems = count;
    _total = total;
  }

  Future<bool> _run(Future<Map<String, dynamic>> Function() action) async {
    if (isLoading) return false;
    final version = _version;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await action();
      if (version != _version) return false;
      _apply(result);
      return true;
    } catch (e) {
      if (version == _version) error = e.toString();
      return false;
    } finally {
      if (version == _version) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> loadCart() => _run(api.getCart);
  Future<bool> addToCart(Products product) =>
      _run(() => api.addItem(product.id));
  Future<bool> decrementFromCart(String id) => _run(
    () => api.updateItem(id, (getProductQuantity(id) - 1).clamp(0, 999999)),
  );
  Future<bool> removeFromCart(String id) => _run(() => api.removeItem(id));
  Future<bool> clearCart() => _run(api.clearCart);

  Future<Map<String, dynamic>?> checkout() async {
    if (isLoading || cartItems.isEmpty) return null;
    final version = _version;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final order = await api.createOrder();
      if (version != _version) return null;
      cartItems = [];
      totalItems = 0;
      _total = 0;
      return order;
    } catch (e) {
      if (version == _version) error = e.toString();
      return null;
    } finally {
      if (version == _version) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    ++_version;
    api.auth.removeListener(_sessionChanged);
    super.dispose();
  }
}
