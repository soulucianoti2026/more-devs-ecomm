import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/categories_section.dart';
//import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/category_card.dart';
import 'package:more_devs_do_zero/shared/widgets/home_appbar.dart';
import 'package:more_devs_do_zero/shared/widgets/product_card.dart';
import 'package:more_devs_do_zero/shared/widgets/products_section.dart';
//import 'package:more_devs_do_zero/shared/mocks.dart';
//import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HomeController>()
        ..getCategories()
        ..getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: Consumer<HomeController>(
        builder: (context, homeController, child) {
          return Column(
            children: [
              CategoriesSection(
                categories: homeController.categories,
                state: homeController.categoriesViewState,
              ), //Sizedbox
              ProductsSection(
                products: homeController.products,
                state: homeController.productsViewState,
              ),
              AppElevatedButton(
                label: 'asdasd',
                type: ButtonType.filled,
                onPressed: () {
                  homeController
                    ..getCategories()
                    ..getProducts();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
