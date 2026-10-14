import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/widgets/banner_item.dart';
import 'package:more_devs_do_zero/features/home/widgets/categories_section.dart';
import 'package:more_devs_do_zero/features/home/widgets/products_section.dart';
import 'package:more_devs_do_zero/features/home/widgets/smooth_page_indicator.dart';
import 'package:more_devs_do_zero/shared/widgets/home_appbar.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';

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
      if (!mounted) return;
      context.read<ShoppingCartController>().loadCart();
      _refreshProfile();
      context.read<HomeController>()
        ..getCategories()
        ..getProducts();
    });
  }

  Future<void> _refreshProfile() async {
    try {
      await context.read<LoginController>().refreshUser(
        context.read<StoreService>(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<BannerItem> bannerItems = [
      const BannerItem(
        title: 'Promoção de Rabanetes',
        urlImage: 'assets/images/rabanete.jpg',
      ),
      const BannerItem(
        title: 'Promoção de Acerolas',
        urlImage: 'assets/images/acerola2.jpg',
      ),
      const BannerItem(
        title: 'Promoção de Batata Pringles',
        urlImage: 'assets/images/pringles3.jpg',
      ),
    ];
    return Scaffold(
      appBar: HomeAppBar(),
      body: Consumer<HomeController>(
        builder: (context, homeController, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                homeController.getCategories(),
                homeController.getProducts(),
                _refreshProfile(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          );
        },
      ),
    );
  }
}
