import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';

Future<void> runCartAction(
  BuildContext context,
  ShoppingCartController cart,
  Future<bool> Function() action,
) async {
  final success = await action();
  if (!context.mounted || success || cart.error == null) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(cart.error!)));
}
