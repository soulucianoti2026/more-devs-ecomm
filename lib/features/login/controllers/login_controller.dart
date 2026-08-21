import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final int _caracterMinimoSenha = 6;
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  bool isActiveCheckBox = false;
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  bool isLoading = false;

  bool get isEmailValid => _emailRegex.hasMatch(emailController.text.trim());
  bool get isSenhaValid =>
      senhaController.text.trim().length >= _caracterMinimoSenha;

  void changeActiveCheckBox() {
    isActiveCheckBox = !isActiveCheckBox;
    notifyListeners();
  }



Future<void> handleLogin() async {
    if (key.currentState!.validate()) {
        isLoading = true;
     
        await login();
        isLoading = false;
      
    }
  }

  Future<void> login() async {
    //Simula chamada da API
    await Future.delayed(const Duration(seconds: 2));
    print('Login realizado com sucesso');
  }

  String? validateEmail(String? value) {
    if (_emailRegex.hasMatch(emailController.text)) {
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
