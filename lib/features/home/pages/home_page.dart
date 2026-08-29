import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/categories_section.dart';
//import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/widgets/home_appbar.dart';
import 'package:more_devs_do_zero/shared/widgets/products_section.dart';
//import 'package:more_devs_do_zero/shared/mocks.dart';
//import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:banner_image/banner_image.dart';

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
              BannerImage(
                itemLength: 1,
                children: [
                  // Example of using an asset image. Add your image file
                  // to `assets/images/mushrooms.jpg` (or change the path).
                  Image.asset(
                    'assets/images/mushrooms.jpg',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),

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
