import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/home/controllers/products_by_category_controller.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_controller.dart';
import 'package:more_devs_do_zero/routes.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService()
            ..onSessionExpired = () {
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                LoginPage.route,
                (_) => false,
              );
            },
        ),
        Provider(
          create: (context) => StoreService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) {
            return LoginController(authService: context.read<AuthService>());
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return HomeController(context.read<StoreService>());
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return ProductsByCategoryController(context.read<StoreService>());
          },
        ),

        ChangeNotifierProvider(
          create: (context) {
            return ShoppingCartController(context.read<StoreService>());
          },
        ),
      ],

      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
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
