import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Products product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(product.name, style: AppTextStyle.smallGrey),
          Text(product.brand, style: AppTextStyle.smallGrey),
          Text(product.price.toString(), style: AppTextStyle.smallBlack),
        ],
      ),
    );
  }
}
