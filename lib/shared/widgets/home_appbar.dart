import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_page.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/cart_icon_button.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<LoginController>(
        builder: (context, loginController, child) {
          final userName = loginController.user?.nome ?? 'Usuário';

          return Text('Olá $userName', style: AppTextStyle.title);
        },
      ),
      actions: [
        CartIconButton(
          onPressed: () {
            Navigator.pushNamed(context, ShoppingCartPage.route);
          },
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.route,
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
