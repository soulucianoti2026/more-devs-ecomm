import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/mocks/mock_auth.dart';

class LoginController extends ChangeNotifier {
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final int _caracterMinimoSenha = 6;
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  bool isActiveCheckBox = false;

  User? user;

  bool isLoading = false;

  bool get isEmailValid => _emailRegex.hasMatch(emailController.text.trim());
  bool get isSenhaValid =>
      senhaController.text.trim().length >= _caracterMinimoSenha;

  void changeActiveCheckBox() {
    isActiveCheckBox = !isActiveCheckBox;
    notifyListeners();
  }

  void changeIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> init() async {
    await Future.microtask(() {
      final users = MockAuth.users;
      if (users.isNotEmpty) {
        final lastUser = users.last;
        emailController.text = lastUser.email;
        isActiveCheckBox = true;
        notifyListeners();
      }
    });
  }

  Future<void> handleLogin() async {
    if (!key.currentState!.validate()) {
      throw ErrorDescription('Validacao_incorreta');
    }

    changeIsLoading(true);
    try {
      await login();
    } finally {
      changeIsLoading(false);
    }
  }

  Future<void> login() async {
    await Future.delayed(const Duration(seconds: 2));

    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (!MockAuth.authenticate(email: email, senha: senha)) {
      throw AuthExeception('Email ou senha incorretos.');
    }

    final registeredUser = MockAuth.getUser(email);
    user = registeredUser ?? User(nome: 'Usuário', email: email);

    if (isActiveCheckBox) {
      MockAuth.registerUser(
        nome: user?.nome ?? 'Usuário',
        email: email,
        senha: senha,
      );
    }

    emailController.clear();
    senhaController.clear();
  }

  String? validateEmail(String? value) {
    if (_emailRegex.hasMatch(emailController.text.trim())) {
      return null;
    }
    return 'E-mail inválido';
  }

  String? validateSenha(String? value) {
    if (senhaController.text.length >= _caracterMinimoSenha) {
      return null;
    }
    return 'Senha inválida';
  }
}
