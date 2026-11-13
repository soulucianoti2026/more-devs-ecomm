import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/features/orders/orders_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/shared/analytics_mixin.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  static const route = '/checkout';

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with AnalyticsMixin {
  bool _submitting = false;

  @override
  String get screenName => CheckoutPage.route;

  @override
  void initState() {
    super.initState();
    logScreenView();
  }

  Future<void> _confirm(ShoppingCartController cart) async {
    if (_submitting || cart.isLoading || cart.cartItems.isEmpty) return;
    setState(() => _submitting = true);
    // Keep the purchased items before checkout clears the cart.
    final items = List<CartProduct>.of(cart.cartItems);
    final total = cart.getTotalPrice();
    final order = await cart.checkout();
    if (order != null) {
      analytics.logPurchase(
        items,
        total,
        transactionId: order['id'].toString(),
      );
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    if (order == null) {
      if (cart.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(cart.error!)));
      }
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pedido criado com sucesso!')));
    Navigator.pushReplacementNamed(
      context,
      OrderDetailPage.route,
      arguments: order['id'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<ShoppingCartController>();
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Finalizar pedido')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            for (final item in cart.cartItems)
              ListTile(
                title: Text(item.name),
                subtitle: Text('Quantidade: ${item.quantity}'),
                trailing: Text('R\$ ${item.subtotal.toStringAsFixed(2)}'),
              ),
            const SizedBox(height: 24),
            Text('Total: R\$ ${cart.getTotalPrice().toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            if (cart.cartItems.isNotEmpty)
              AppElevatedButton(
                label: 'Confirmar Pedido',
                type: ButtonType.filled,
                isLoading: _submitting || cart.isLoading,
                onPressed: () => _confirm(cart),
              ),
          ],
        ),
      ),
    );
  }
}
