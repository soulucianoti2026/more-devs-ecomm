import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';

class ProductsByCategoryPage extends StatefulWidget {
  const ProductsByCategoryPage({super.key, required this.categoryName});

  @override
  State<ProductsByCategoryPage> createState() => _ProductsByCategoryPageState();

  static const String route = '/products-by-category';

  final String categoryName;
}

class _ProductsByCategoryPageState extends State<ProductsByCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.categoryName, style: AppTextStyle.title),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Container(),
    );
  }
}
