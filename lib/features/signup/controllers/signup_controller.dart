import 'package:flutter/material.dart';

class SignupController {
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  TextEditingController emailController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  TextEditingController confirmarSenhaController = TextEditingController();

  bool isActiveCheckBox = false;
  bool checkBoxError = false;
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

  void changeActiveCheckBox() {
    isActiveCheckBox = !isActiveCheckBox;
    if (isActiveCheckBox) {
      checkBoxError = false;
    }
  }

  /// Valida o checkbox e retorna se estão com erro
  bool validateCheckBox() {
    checkBoxError = !isActiveCheckBox;
    return isActiveCheckBox;
  }

  /// Verifica se o formulário é válido
  bool isFormValid(FormState formState) {
    return formState.validate();
  }

  /// Valida todos os requisitos: formulário + checkbox da política
  /// Retorna true se pode fazer o signup (tudo passou na validação)
  /// Se formulário está OK mas checkbox não está marcado, marca o checkbox com erro e retorna false
  bool validateAllRequirements(FormState formState) {
    final formIsValid = isFormValid(formState);

    if (formIsValid && !isActiveCheckBox) {
      // Formulário OK, mas checkbox de política/termos não marcado
      checkBoxError = true;
      return false;
    }

    if (!formIsValid) {
      // Formulário com erros
      return false;
    }

    // Tudo validado com sucesso
    checkBoxError = false;
    return true;
  }

  /// Executa o signup com loading
  /// Deve ser chamado após validação bem-sucedida
  Future<void> executeSignUp() async {
    isLoading = true;
    await Future.delayed(Duration(seconds: 2));
    isLoading = false;
  }

  Future<void> signUp() async {
    await Future.delayed(Duration(seconds: 2));
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


