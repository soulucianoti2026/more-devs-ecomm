import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/widgets/banner_item.dart';
import 'package:more_devs_do_zero/features/home/widgets/smooth_page_indicator.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/features/home/widgets/categories_section.dart';
//import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/widgets/home_appbar.dart';
import 'package:more_devs_do_zero/features/home/widgets/products_section.dart';
//import 'package:more_devs_do_zero/shared/mocks.dart';
//import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    List<BannerItem> bannerItems = [
      const BannerItem(
        title: 'Promoção de Rabanetes',
        urlImage: 'assets/images/rabanete.jpg',
      ),
      const BannerItem(
        title: 'Promoção de Cenouras',
        urlImage: 'assets/images/rabanete.jpg',
      ),
      const BannerItem(
        title: 'Promoção de Beterrabas',
        urlImage: 'assets/images/rabanete.jpg',
      ),
    ];
    return Scaffold(
      appBar: HomeAppBar(),

      body: Consumer<HomeController>(
        builder: (context, homeController, child) {
          return Column(
            children: [
              SizedBox(
                height: 156,
                child: PageView(
                  controller: _pageController,
                  children: [for (var banner in bannerItems) banner],
                ),
              ),
              SizedBox(height: 8),

              smoothPageIndicator(
                pageController: _pageController,
                bannerItems: bannerItems,
              ),
              CategoriesSection(
                categories: homeController.categories,
                state: homeController.categoriesViewState,
              ), //

              SizedBox(height: 4), // Espaçamento entre categorias e produtos
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
