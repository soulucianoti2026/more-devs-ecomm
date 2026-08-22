import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/signup/controllers/signup_controller.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/app_check_box.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/app_required_password.dart';
import 'package:more_devs_do_zero/shared/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static const String route = '/signup';

  

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro'), centerTitle: true),
      body: SingleChildScrollView(
        child: SizedBox(
          height:  MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -  MediaQuery.of(context).padding.bottom,
          child: SafeArea(
            child: Consumer<SignupController>(
              builder: (context, controller, child) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                key: controller.key,
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
                      controller: controller.emailController,
                      hintText: 'email@dominio.com',
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: controller.nomeController,
                      hintText: 'nome',
                      validator: controller.validateNome,
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: controller.senhaController,
                      hintText: 'senha',
                      onChanged: (_) => controller.updatePasswordRequirements(),
                      validator: controller.validateSenha,
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    AppTextField(
                      controller: controller.confirmarSenhaController,
                      hintText: 'confirmar senha',
                      onChanged: (_) => controller.updatePasswordRequirements(),
                      validator: controller.validateConfirmarSenha,
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    for (var requiremnt
                        in controller.getPasswordRequirements())
                      AppRequiredPassword(
                        atendido: requiremnt.values.first,
                        text: requiremnt.keys.first,
                      ),
          
                    Spacer(),
                    Row(
                      children: [
                        AppCheckBox(
                          value: controller.isActiveCheckBox,
                          isError: controller.checkBoxError,
                          onChanged: (_) => controller.changeActiveCheckBox(),
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
                      isLoading: controller.isLoading,
                      onPressed: () => controller.executeSignUp(),
                      type: ButtonType.filled,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
