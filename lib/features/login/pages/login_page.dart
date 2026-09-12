import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/pages/home_page.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/recover/pages/recover_page.dart';
import 'package:more_devs_do_zero/features/signup/pages/signup_page.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/widgets/app_check_box.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String route = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<LoginController>();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Safearea desconta espa  ços do disposito ex: barra superior
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Consumer<LoginController>(
                  builder: (context, controller, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: controller.key,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Image.asset('assets/images/logo.png', height: 120),
                            Center(
                              child: Text(
                                '+DevsEcomm',
                                style: AppTextStyle.title,
                              ),
                            ),
                            const SizedBox(height: 48),
                            AppTextField(
                              controller: controller.emailController,
                              validator: (value) {
                                return controller.validateEmail(value);
                              },
                              hintText: 'email@dominio.com',
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: controller.senhaController,
                              validator: (value) {
                                return controller.validateSenha(value);
                              },
                              hintText: '****************',
                              obscureText: true,
                            ),
                            Row(
                              children: [
                                AppCheckBox(
                                  value: controller.isActiveCheckBox,
                                  onChanged: (value) =>
                                      controller.changeActiveCheckBox(),
                                ),
                                const Text('Lembrar-me'),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    RecoverPage.route,
                                  );
                                },
                                child: Text(
                                  'Esqueci minha senha',
                                  style: AppTextStyle.smallBlack,
                                ),
                              ),
                            ),
                            AppElevatedButton(
                              label: 'Entrar',
                              isLoading: controller.isLoading,
                              onPressed: () async {
                                try {
                                  await controller.handleLogin();
                                  if (!context.mounted) return;
                                  Navigator.popAndPushNamed(
                                    context,
                                    HomePage.route,
                                  );
                                } on AuthExeception catch (e) {
                                  if (!context.mounted) return;
                                  AnimatedSnackBar.material(
                                    e.message,
                                    type: AnimatedSnackBarType.error,
                                    mobileSnackBarPosition:
                                        MobileSnackBarPosition.bottom,
                                  ).show(context);
                                }
                              },
                              type: ButtonType.filled,
                            ),
                            const SizedBox(height: 12),
                            AppElevatedButton(
                              label: 'Cadastrar',
                              onPressed: () {
                                Navigator.pushNamed(context, SignupPage.route);
                              },
                              type: ButtonType.outlined,
                            ),
                            const SizedBox(height: 48),
                            GestureDetector(
                              onTap: () {
                                // print('CLIQUEI NA LINHA');
                              },
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Termos de Serviço ',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    const TextSpan(
                                      text: 'e ',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    const TextSpan(
                                      text: 'Politicas de Privacidade',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
