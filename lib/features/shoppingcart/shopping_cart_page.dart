import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/widgets/quantity_selector.dart';
import 'package:more_devs_do_zero/features/shoppingcart/confirm_product_removal.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:provider/provider.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  static const String route = '/shopping-cart';

  @override
  State<ShoppingCartPage> createState() => ShoppingCartPageState();
}

class ShoppingCartPageState extends State<ShoppingCartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Carrinho',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<ShoppingCartController>(
        builder: (context, controller, child) {
          if (controller.cartItems.isEmpty) {
            return const Center(child: Text('Seu carrinho está vazio.'));
          }

          return Stack(
            children: [
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: controller.cartItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  final name = item.name;
                  final price = item.price;
                  final quantity = item.quantity;
                  final imageUrl = item.imageUrl;
                  final isAssetImage = imageUrl.startsWith('assets/');
                  final subtotal = price * quantity;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isAssetImage
                                ? Image.asset(
                                    imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 72,
                                        height: 72,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      );
                                    },
                                  )
                                : Image.network(
                                    imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 72,
                                        height: 72,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Qtd: $quantity'),
                                Text(
                                  'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subtotal: R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                QuantitySelector(
                                  product: item,
                                  quantity: quantity,
                                  subtotal: subtotal,
                                  increment: () {
                                    controller.addToCart(item);
                                  },
                                  decrement: () {
                                    controller.decrementFromCart(name);
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final confirmed = await confirmProductRemoval(
                                context,
                                name,
                              );
                              if (!context.mounted || !confirmed) return;
                              controller.removeFromCart(name);
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'R\$ ${controller.getTotalPrice().toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
