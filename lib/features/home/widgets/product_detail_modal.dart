import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/home/widgets/quantity_selector.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'package:more_devs_do_zero/shared/widgets/api_action.dart';

Future<void> showProductDetailModal(
  BuildContext context,
  Products product,
) async {
  if (product.id.isEmpty) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return _ProductLoader(product: product);
    },
  );
}

class _ProductLoader extends StatefulWidget {
  const _ProductLoader({required this.product});
  final Products product;
  @override
  State<_ProductLoader> createState() => _ProductLoaderState();
}

class _ProductLoaderState extends State<_ProductLoader> {
  late Future<Products> _future;
  @override
  void initState() {
    super.initState();
    _future = context.read<StoreService>().getProduct(widget.product.id);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Products>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (snapshot.hasError) {
        return Material(
          child: SizedBox(
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(snapshot.error.toString()),
                TextButton(
                  onPressed: () => setState(() {
                    _future = context.read<StoreService>().getProduct(
                      widget.product.id,
                    );
                  }),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        );
      }
      return _ProductDetailModal(product: snapshot.data!);
    },
  );
}

class _ProductDetailModal extends StatelessWidget {
  const _ProductDetailModal({required this.product});

  final Products product;

  @override
  Widget build(BuildContext context) {
    final description = product.description;

    return SafeArea(
      top: false,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: Container(
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 1.8,
                      child: (() {
                        final isAssetImage = product.imageUrl.startsWith(
                          'assets/',
                        );
                        return isAssetImage
                            ? Image.asset(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const ColoredBox(
                                    color: Color(0xffeeeeee),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  );
                                },
                              )
                            : Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const ColoredBox(
                                    color: Color(0xffeeeeee),
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  );
                                },
                              );
                      })(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<ShoppingCartController>(
                    builder: (context, cartController, child) {
                      final quantity = cartController.getProductQuantity(
                        product.id,
                      );

                      if (quantity > 0) {
                        final subtotal = cartController.getProductSubtotal(
                          product.id,
                        );

                        return QuantitySelector(
                          enabled: !cartController.isLoading,
                          product: product,
                          quantity: quantity,
                          subtotal: subtotal,
                          increment: () {
                            runCartAction(
                              context,
                              cartController,
                              () => cartController.addToCart(product),
                            );
                          },
                          decrement: () {
                            runCartAction(
                              context,
                              cartController,
                              () =>
                                  cartController.decrementFromCart(product.id),
                            );
                          },
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: cartController.isLoading
                              ? null
                              : () => runCartAction(
                                  context,
                                  cartController,
                                  () => cartController.addToCart(product),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Adicionar no carrinho'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
