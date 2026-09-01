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
  int _currentPage = 0; // Controla qual bolinha destacar
  final PageController _pageController = PageController();

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
                itemLength: 2,
                selectedIndicatorColor: Colors.black,
                indicatorColor: Colors.grey.shade400,
                children: [
                  Container(
                    height: 140,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.from(
                        alpha: 1,
                        red: 0.827,
                        green: 0.839,
                        blue: 0.839,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              // Cor de fundo da coluna
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Aproveite as ofertas',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight(600),

                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/rabanete.jpg',
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 140,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.from(
                        alpha: 1,
                        red: 0.827,
                        green: 0.839,
                        blue: 0.839,
                      ), // Uma cor de fundo diferente se quiser
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Experimente agora!', // Novo Texto
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight
                                        .w600, // Correção do FontWeight
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/cogumelos.jpg', // Substitua pelo caminho do seu segundo banner
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                      ],
                    ),
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

              // AppElevatedButton(
              //   label: 'asdasd',
              //   type: ButtonType.filled,
              //   onPressed: () {
              //     homeController
              //       ..getCategories()
              //       ..getProducts();
              //},
            ],
          );
        },
      ),
    );
  }
}
