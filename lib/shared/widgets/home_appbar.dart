import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/shoppingcart/shopping_cart_page.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/cart_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/features/orders/orders_page.dart';
import 'package:more_devs_do_zero/features/profile/profile_page.dart';

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
        IconButton(
          tooltip: 'Minha conta',
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pushNamed(context, ProfilePage.route),
        ),
        IconButton(
          tooltip: 'Meus pedidos',
          icon: const Icon(Icons.receipt_long_outlined),
          onPressed: () => Navigator.pushNamed(context, OrdersPage.route),
        ),
        CartIconButton(
          onPressed: () {
            Navigator.pushNamed(context, ShoppingCartPage.route);
          },
        ),
        IconButton(
          onPressed: () {
            context.read<LoginController>().logout();
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
