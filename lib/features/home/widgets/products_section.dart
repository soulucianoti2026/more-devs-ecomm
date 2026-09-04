import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/home/widgets/product_card.dart';
//import 'package:more_devs_do_zero/features/home/pages/product_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductsSection extends StatelessWidget {
  const ProductsSection({
    super.key,
    required this.products,
    required this.state,
  });

  final List<Products> products;
  final ProductsViewState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ProductsViewState.error => const SizedBox(
        height: 220,
        child: Center(child: Text('Problema ao resgatar produtos.')),
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //TITULO "PRODUTOS" ADICIONADO AQUI.
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Produtos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.black, size: 20),
              ],
            ),
          ),

          SizedBox(
            height: 220,

            child: Skeletonizer(
              enabled: state == ProductsViewState.loading,
              child: ListView.builder(
                itemCount: getProductList().length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Products product = getProductList()[index];
                  return ProductCard(product: product);
                },
              ),
            ),
          ),
        ],
      ),
    };
  }

  List<Products> getProductList() {
    return state == ProductsViewState.loading
        ? [
            Products(
              brand: 'asda',
              name: 'asdda',
              imageUrl: '',
              price: 1.0,
              category: 'Frutas',
            ),
            Products(
              brand: 'asda',
              name: 'asdda',
              imageUrl: '',
              price: 1.0,
              category: 'Verduras',
            ),
            Products(
              brand: 'asda',
              name: 'asdda',
              imageUrl: '',
              price: 1.0,
              category: 'Padaria',
            ),
            Products(
              brand: 'asda',
              name: 'asdda',
              imageUrl: '',
              price: 1.0,
              category: 'Importados',
            ),
          ]
        : products;
  }
}
