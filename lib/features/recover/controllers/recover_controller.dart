import 'package:more_devs_do_zero/shared/services/auth_service.dart';

enum RecoveryStep { email, code, password }

class RecoverController {
  RecoverController({AuthService? authService})
    : _authService = authService ?? AuthService();
  final AuthService _authService;
  String email = '';
  String? _resetToken;
  RecoveryStep step = RecoveryStep.email;
  bool isLoading = false;

  Future<void> sendCode(String value) async {
    final normalized = value.trim();
    await _authService.forgotPassword(normalized);
    email = normalized;
    _resetToken = null;
    step = RecoveryStep.code;
  }

  Future<void> verifyCode(String code) async {
    _resetToken = await _authService.verifyCode(email: email, code: code);
    step = RecoveryStep.password;
  }

  Future<void> resetPassword(String password, String confirmation) async {
    await _authService.resetPassword(
      resetToken: _resetToken!,
      password: password,
      confirmPassword: confirmation,
    );
    restart();
  }

  void restart() {
    _resetToken = null;
    step = RecoveryStep.email;
  }
}
