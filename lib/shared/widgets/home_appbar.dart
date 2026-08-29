import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<LoginController>(
        builder: (context, loginController, child) {
          // Evita erros caso o usuário ainda não tenha sido carregado
          final userName = loginController.user?.nome ?? 'Usuário';

          return Text('Olá $userName', style: AppTextStyle.title);
        },
      ),
    );
  }

  // Define a altura padrão do AppBar (56.0 logic pixels no Material Design)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
