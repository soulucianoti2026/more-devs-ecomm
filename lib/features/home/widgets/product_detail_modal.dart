import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:provider/provider.dart';

Future<void> showProductDetailModal(
  BuildContext context,
  Products product,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      return _ProductDetailModal(product: product);
    },
  );
}

class _ProductDetailModal extends StatelessWidget {
  const _ProductDetailModal({required this.product});

  final Products product;

  @override
  Widget build(BuildContext context) {
    final description =
        'A ${product.name.toLowerCase()} e uma fruta tropical conhecida pelo seu '
        'sabor refrescante, levemente acido e naturalmente adocicado. '
        'Rica em vitamina C e muito versatil, pode ser consumida in natura, '
        'utilizada em sucos, vitaminas, sobremesas e diversas receitas.';

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
                  Text(
                    'Ideal para quem busca uma opcao saborosa e nutritiva para o '
                    'dia a dia. Produto selecionado para garantir qualidade, '
                    'frescor e sabor.',
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
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
                        product.name,
                      );

                      if (quantity > 0) {
                        return Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    cartController.decrementFromCart(product.name);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: const Icon(Icons.remove),
                                ),
                              ),
                              Container(
                                width: 64,
                                alignment: Alignment.center,
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () {
                                    cartController.addToCart(product);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<ShoppingCartController>().addToCart(
                              product,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} adicionado ao carrinho',
                                ),
                              ),
                            );
                          },
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
