import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/signup/controllers/signup_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/app_check_box.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/app_required_password.dart';
import 'package:more_devs_do_zero/shared/widgets/app_text_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  static const String route = '/signup';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  SignupController signupController = SignupController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  Future<void> _handleSignup() async {
    final isFormValid = key.currentState!.validate();

    if (!signupController.validateCheckBox()) {
      setState(() {});
      return;
    }

    if (isFormValid && signupController.isActiveCheckBox) {
      setState(() {
        signupController.isLoading = true;
      });

      await signupController.signUp();

      setState(() {
        signupController.isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24),
                Center(
                  child: Text(
                    'Criar uma conta',
                    style: AppTextStyle.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Insira seus dados para iniciar suas compras',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32),
                AppTextField(
                  controller: signupController.emailController,
                  hintText: 'email@dominio.com',
                  validator: signupController.validateEmail,
                ),
                SizedBox(height: 16),
                AppTextField(
                  controller: signupController.nomeController,
                  hintText: 'nome',
                  validator: signupController.validateNome,
                ),
                SizedBox(height: 16),
                AppTextField(
                  controller: signupController.senhaController,
                  hintText: 'senha',
                  onChanged: (value) => setState(() {}),
                  validator: signupController.validateSenha,
                  obscureText: true,
                ),
                SizedBox(height: 16),
                AppTextField(
                  controller: signupController.confirmarSenhaController,
                  hintText: 'confirmar senha',
                  onChanged: (value) => setState(() {}),
                  validator: signupController.validateConfirmarSenha,
                  obscureText: true,
                ),
                SizedBox(height: 16),
                for (var requiremnt
                    in signupController.getPasswordRequirements())
                  AppRequiredPassword(
                    atendido: requiremnt.values.first,
                    text: requiremnt.keys.first,
                  ),

                Spacer(),
                Row(
                  children: [
                    AppCheckBox(
                      isError: signupController.checkBoxError,
                      value: signupController.isActiveCheckBox,
                      onChanged: (value) {
                        setState(() {
                          signupController.changeActiveCheckBox();
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('CLIQUEI NA LINHA');
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text:
                                    'Ao clicar em continuar, você concorda com os nossos',
                              ),
                              TextSpan(
                                text: 'Termos de Serviço ',
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(text: 'e com a '),
                              TextSpan(
                                text: 'Politica de Privacidade',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                AppElevatedButton(
                  label: 'Continuar',
                  isLoading: signupController.isLoading,
                  onPressed: _handleSignup,
                  type: ButtonType.filled,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
