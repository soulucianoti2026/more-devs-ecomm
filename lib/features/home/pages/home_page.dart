import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String route = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<HomeController>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LoginController>(
          builder: (context, loginController, child) {
            return Text(
              'Olá ${loginController.user!.nome}',
              style: AppTextStyle.title,
            );
          },
        ),
      ),
      body: Consumer<HomeController>(
        builder: (context, HomeController, child) {
          return Column(
            children: [
              SizedBox(
                height: 108,
                child: switch (HomeController.categoriesViewState) {
                  CategoriesViewState.loading => Center(
                    child: CircularProgressIndicator(),
                  ),
                  CategoriesViewState.error => Text(
                    'Problema ao restagar categorias',
                  ),
                  CategoriesViewState.sucess => Container(
                    color: Colors.red,
                    width: 100,
                    height: 100,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
