import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/recover/controllers/recover_controller.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/widgets/app_elevated_button.dart';
import 'package:more_devs_do_zero/shared/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key});
  static const String route = '/recover';

  @override
  State<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  late final RecoverController _controller;
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = RecoverController(authService: context.read<AuthService>());
  }

  @override
  void dispose() {
    for (final controller in [_email, _code, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _controller.isLoading = true);
    try {
      switch (_controller.step) {
        case RecoveryStep.email:
          await _controller.sendCode(_email.text);
          if (!mounted) return;
          _showMessage(
            'Se o e-mail estiver cadastrado, você receberá um código.',
          );
        case RecoveryStep.code:
          await _controller.verifyCode(_code.text);
        case RecoveryStep.password:
          await _controller.resetPassword(_password.text, _confirmation.text);
          if (!mounted) return;
          context.read<LoginController>().logout();
          _showMessage(
            'Senha alterada com sucesso. Faça login com a nova senha.',
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(LoginPage.route, (_) => false);
      }
    } on AuthExeception catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } finally {
      if (mounted) setState(() => _controller.isLoading = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    AnimatedSnackBar.material(
      message,
      type: error ? AnimatedSnackBarType.error : AnimatedSnackBarType.success,
      mobileSnackBarPosition: MobileSnackBarPosition.bottom,
    ).show(context);
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 6 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Use 6 caracteres, maiúscula, minúscula e símbolo.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final step = _controller.step;
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (step == RecoveryStep.email)
                  AppTextField(
                    key: const ValueKey('recovery-email'),
                    controller: _email,
                    hintText: 'email@dominio.com',
                    validator: (value) =>
                        RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(value?.trim() ?? '')
                        ? null
                        : 'E-mail inválido',
                  ),
                if (step == RecoveryStep.code) ...[
                  Text(
                    'Digite o código de 6 dígitos enviado para ${_controller.email}.',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    key: const ValueKey('recovery-code'),
                    controller: _code,
                    hintText: 'Código de 6 dígitos',
                    validator: (value) =>
                        RegExp(r'^\d{6}$').hasMatch(value?.trim() ?? '')
                        ? null
                        : 'Informe os 6 dígitos do código',
                  ),
                ],
                if (step == RecoveryStep.password) ...[
                  const Text(
                    'Use no mínimo 6 caracteres, uma letra maiúscula, uma minúscula e um símbolo.',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    key: const ValueKey('recovery-password'),
                    controller: _password,
                    hintText: 'Nova senha',
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmation,
                    hintText: 'Confirmar nova senha',
                    obscureText: true,
                    validator: (value) => value == _password.text
                        ? null
                        : 'As senhas não coincidem',
                  ),
                ],
                const SizedBox(height: 24),
                AppElevatedButton(
                  label: switch (step) {
                    RecoveryStep.email => 'Enviar código',
                    RecoveryStep.code => 'Validar código',
                    RecoveryStep.password => 'Alterar senha',
                  },
                  type: ButtonType.filled,
                  isLoading: _controller.isLoading,
                  onPressed: _submit,
                ),
                if (step != RecoveryStep.email)
                  TextButton(
                    onPressed: _controller.isLoading
                        ? null
                        : () {
                            setState(() {
                              _controller.restart();
                              _code.clear();
                              _password.clear();
                              _confirmation.clear();
                            });
                          },
                    child: const Text('Solicitar outro código'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
