import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/widgets/product_card.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';

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
    return SizedBox(
      height: 230,
      child: switch (state) {
        ProductsViewState.loading => Center(child: CircularProgressIndicator()),
        ProductsViewState.error => Text('Problema ao restagar categorias'),
        ProductsViewState.sucess => SizedBox(
          // height: 200,
          child: ListView.builder(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Products product = products[index];
              return Container(
                margin: EdgeInsets.all(10),

                //height: 50,
                //width: 50,
                child: ProductCard(product: product),
              );
            },
          ),
        ),
      },
    );
  }
}
