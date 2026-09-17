import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/controllers/products_by_category_controller.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/routes.dart';
import 'package:more_devs_do_zero/shared/mocks/mock_auth.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockAuth.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return LoginController();
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return HomeController();
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return ProductsByCategoryController();
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return ShoppingCartController();
          },
        ),
      ],

      builder: (context, child) {
        return MaterialApp(
          builder: (context, child) {
            return ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          routes: AppRoutes.routes,
          initialRoute: LoginPage.route,
        );
      },
    );
  }
}
