import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/widgets/product_card.dart';
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
    return SizedBox(
      //height: 200,
      child: switch (state) {
        ProductsViewState.error => Text('Problema ao restagar categorias'),
        _ => SizedBox(
          height: 200,
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
      },
    );
  }

  List<Products> getProductList() {
    return state == ProductsViewState.loading
        ? [
            Products(brand: 'asda', name: 'asdda', imageUrl: '', price: 1.0),
            Products(brand: 'asda', name: 'asdda', imageUrl: '', price: 1.0),
            Products(brand: 'asda', name: 'asdda', imageUrl: '', price: 1.0),
            Products(brand: 'asda', name: 'asdda', imageUrl: '', price: 1.0),
          ]
        : products;
  }
}
