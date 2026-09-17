import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/home/widgets/product_detail_modal.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Products product;

  @override
  Widget build(BuildContext context) {
    final isAssetImage = product.imageUrl.startsWith('assets/');

    return GestureDetector(
      onTap: () => showProductDetailModal(context, product),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: isAssetImage
                      ? AssetImage(product.imageUrl)
                      : NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(product.name, style: AppTextStyle.smallGrey),
            Text(product.brand, style: AppTextStyle.smallGrey),
            Text(
              'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTextStyle.smallBlack,
            ),
          ],
        ),
      ),
    );
  }
}
