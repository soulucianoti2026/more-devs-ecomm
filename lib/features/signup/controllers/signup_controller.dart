import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/shared/mocks/mock_auth.dart';

class SignupController {
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  TextEditingController emailController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController confirmarSenhaController = TextEditingController();

  bool checkBoxError = false;

  bool isActiveCheckBox = false;
  bool isLoading = false;

  List<Map<String, bool>> getPasswordRequirements() {
    return [
      {'Mínimo de 6 caracteres': minSeisCaracteres},
      {'No mínimo um caracter especial': possuiCaractereEspecial},
      {'No mínimo uma letra maiúscula': possuiLetraMaiuscula},
      {'No mínimo uma letra minúscula': possuiLetraMinuscula},
      {'Senhas coincidem': senhasCoincidentes},
    ];
  }

  bool validateCheckBox() {
    checkBoxError = !isActiveCheckBox;
    return isActiveCheckBox;
  }

  void changeActiveCheckBox() {
    isActiveCheckBox = !isActiveCheckBox;
    if (isActiveCheckBox) {
      checkBoxError = false;
      if (validateEmail(emailController.text) == null &&
          validateNome(nomeController.text) == null &&
          validateSenha(senhaController.text) == null &&
          validateConfirmarSenha(confirmarSenhaController.text) == null) {
        saveToMockAuth();
      }
    }
  }

  void saveToMockAuth() {
    MockAuth.registerUser(
      nome: nomeController.text,
      email: emailController.text,
      senha: senhaController.text,
    );
  }

  Future<void> signUp() async {
    await Future.delayed(const Duration(seconds: 2));
    saveToMockAuth();
  }

  String? validateEmail(String? value) {
    if (_emailRegex.hasMatch(emailController.text.trim())) {
      return null;
    }
    return 'E-mail inválido';
  }

  String? validateNome(String? value) {
    if (nomeController.text.trim().isNotEmpty) {
      return null;
    }
    return 'Nome inválido';
  }

  String? validateSenha(String? value) {
    if (minSeisCaracteres &&
        possuiCaractereEspecial &&
        possuiLetraMaiuscula &&
        possuiLetraMinuscula) {
      return null;
    }
    return 'Senha não atende aos requisitos';
  }

  String? validateConfirmarSenha(String? value) {
    if (senhasCoincidentes) {
      return null;
    }
    return 'As senhas não coincidem';
  }

  bool get possuiLetraMaiuscula =>
      senhaController.text.contains(RegExp(r'[A-Z]'));
  bool get possuiLetraMinuscula =>
      senhaController.text.contains(RegExp(r'[a-z]'));
  bool get senhasCoincidentes =>
      senhaController.text == confirmarSenhaController.text &&
      senhaController.text.isNotEmpty;
  bool get minSeisCaracteres => senhaController.text.length >= 6;
  bool get possuiCaractereEspecial =>
      senhaController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
}
