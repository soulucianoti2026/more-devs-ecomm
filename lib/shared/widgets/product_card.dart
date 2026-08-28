import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Products product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(product.imageUrl),
        Text(product.name, style: AppTextStyle.smallGrey),
        Text(product.brand, style: AppTextStyle.smallGrey),
        Text(product.price.toString(), style: AppTextStyle.smallBlack),
      ],
    );
  }
}
