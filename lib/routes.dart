import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/orders/orders_page.dart';
import 'package:more_devs_do_zero/features/profile/profile_page.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/pages/home_page.dart';
import 'package:more_devs_do_zero/features/home/pages/products_by_category_page.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/recover/pages/recover_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_page.dart';
import 'package:more_devs_do_zero/features/signup/pages/signup_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    ProfilePage.route: (_) => const ProfilePage(),
    OrdersPage.route: (_) => const OrdersPage(),
    OrderDetailPage.route: (context) => OrderDetailPage(
      orderId: ModalRoute.of(context)!.settings.arguments as String,
    ),
    LoginPage.route: (context) => const LoginPage(),
    SignupPage.route: (context) => const SignupPage(),
    RecoverPage.route: (context) => const RecoverPage(),
    HomePage.route: (context) => const HomePage(),
    ShoppingCartPage.route: (context) => const ShoppingCartPage(),
    ProductsByCategoryPage.route: (context) {
      final category = ModalRoute.of(context)?.settings.arguments as Category?;
      if (category == null) return const HomePage();
      return ProductsByCategoryPage(category: category);
    },
  };
}
