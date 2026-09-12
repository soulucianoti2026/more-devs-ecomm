import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/widgets/banner_item.dart';
import 'package:more_devs_do_zero/features/home/widgets/categories_section.dart';
import 'package:more_devs_do_zero/features/home/widgets/products_section.dart';
import 'package:more_devs_do_zero/features/home/widgets/smooth_page_indicator.dart';
import 'package:more_devs_do_zero/shared/widgets/home_appbar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<HomeController>()
        ..getCategories()
        ..getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<BannerItem> bannerItems = [
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
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 156,
                  child: PageView(
                    controller: _pageController,
                    children: [for (var banner in bannerItems) banner],
                  ),
                ),
                const SizedBox(height: 8),
                SmoothPageIndicatorWidget(
                  pageController: _pageController,
                  bannerItems: bannerItems,
                ),
                CategoriesSection(
                  categories: homeController.categories,
                  state: homeController.categoriesViewState,
                ),
                const SizedBox(height: 4),
                ProductsSection(
                  products: homeController.products,
                  state: homeController.productsViewState,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
