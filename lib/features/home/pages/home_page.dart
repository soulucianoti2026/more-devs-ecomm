import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
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
      appBar: AppBar(
        title: Consumer<LoginController>(
          builder: (context, loginController, child) {
            return Text(
              'Olá ${loginController.user!.nome}',
              style: AppTextStyle.title,
            );
          },
        ),
      ),
      body: Consumer<HomeController>(
        builder: (context, homeController, child) {
          return Column(
            children: [
              SizedBox(
                height: 145,
                child: switch (homeController.categoriesViewState) {
                  CategoriesViewState.loading => Center(
                    child: CircularProgressIndicator(),
                  ),
                  CategoriesViewState.error => Text(
                    'Problema ao restagar categorias',
                  ),
                  CategoriesViewState.sucess => SizedBox(
                    // height: 200,
                    child: ListView.builder(
                      itemCount: homeController.categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Category category = homeController.categories[index];
                        return Container(
                          margin: EdgeInsets.all(10),

                          //height: 50,
                          //width: 50,
                          child: Column(
                            children: [
                              Image.network(category.imageUrl),
                              Text(
                                category.name,
                                style: AppTextStyle.smallGrey,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                },
              ), //Sizedbox
              SizedBox(
                height: 230,
                child: switch (homeController.productsViewState) {
                  ProductsViewState.loading => Center(
                    child: CircularProgressIndicator(),
                  ),
                  ProductsViewState.error => Text(
                    'Problema ao restagar categorias',
                  ),
                  ProductsViewState.sucess => SizedBox(
                    // height: 200,
                    child: ListView.builder(
                      itemCount: homeController.products.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Products product = homeController.products[index];
                        return Container(
                          margin: EdgeInsets.all(10),

                          //height: 50,
                          //width: 50,
                          child: Column(
                            children: [
                              Image.network(product.imageUrl),
                              Text(product.name, style: AppTextStyle.smallGrey),
                              Text(
                                product.brand,
                                style: AppTextStyle.smallGrey,
                              ),
                              Text(
                                product.price.toString(),
                                style: AppTextStyle.smallBlack,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                },
              ),
              // AppElevatedButton(
              //   label: 'asdasd',
              //   type: ButtonType.filled,
              //   onPressed: () {
              //     homeController
              //       ..getCategories()
              //       ..getproducts();
              //   },
              // ),
            ],
          );
        },
      ),
    );
  }
}
