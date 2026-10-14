import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/products_by_category_controller.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/widgets/product_card.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_page.dart';
import 'package:more_devs_do_zero/shared/widgets/cart_icon_button.dart';
import 'package:provider/provider.dart';

class ProductsByCategoryPage extends StatefulWidget {
  const ProductsByCategoryPage({super.key, required this.category});
  static const route = '/products-by-category';
  final Category category;
  @override
  State<ProductsByCategoryPage> createState() => _ProductsByCategoryPageState();
}

class _ProductsByCategoryPageState extends State<ProductsByCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductsByCategoryController>().getProductsByCategory(
          widget.category.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.category.name),
      actions: [
        CartIconButton(
          onPressed: () => Navigator.pushNamed(context, ShoppingCartPage.route),
        ),
      ],
    ),
    body: Consumer<ProductsByCategoryController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar produtos',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: controller.searchProducts,
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: controller.brand ?? '',
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Todas as marcas'),
                      ),
                      ...controller.brands.map(
                        (brand) =>
                            DropdownMenuItem(value: brand, child: Text(brand)),
                      ),
                    ],
                    onChanged: controller.filterBrand,
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (controller.state) {
                ProductsByCategoryViewState.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                ProductsByCategoryViewState.error => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.error ??
                            'Não foi possível carregar os produtos.',
                      ),
                      TextButton(
                        onPressed: controller.retry,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
                ProductsByCategoryViewState.success =>
                  controller.categoryProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto encontrado.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: controller.categoryProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),
                          itemBuilder: (context, index) => ProductCard(
                            product: controller.categoryProducts[index],
                          ),
                        ),
              },
            ),
          ],
        );
      },
    ),
  );
}
