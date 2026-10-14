import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/exceptions/auth_exeception.dart';
import 'package:more_devs_do_zero/shared/services/auth_service.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _authService.addListener(_onSessionChanged);
  }
  final AuthService _authService;
  late final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final int _caracterMinimoSenha = 6;
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();

  bool isActiveCheckBox = false;

  User? user;

  void _onSessionChanged() {
    user = _authService.session?.user;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onSessionChanged);
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

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
    try {
      final email = await _preferences.getString('remembered_email');
      if (email != null && emailController.text.isEmpty) {
        emailController.text = email;
        isActiveCheckBox = true;
        notifyListeners();
      }
    } catch (_) {
      // A preferência local não impede a autenticação pela API.
    }
  }

  Future<void> handleLogin() async {
    if (!(key.currentState?.validate() ?? false)) {
      throw AuthExeception('Confira o e-mail e a senha informados.');
    }

    changeIsLoading(true);
    try {
      await login();
    } finally {
      changeIsLoading(false);
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final session = await _authService.login(
      email: email,
      password: senhaController.text,
    );
    user = session.user;
    try {
      if (isActiveCheckBox) {
        await _preferences.setString('remembered_email', email);
      } else {
        await _preferences.remove('remembered_email');
      }
    } catch (_) {
      // O login continua válido se a preferência não puder ser salva.
    }

    emailController.clear();
    senhaController.clear();
  }

  void acceptSession(AuthSession session) {
    user = session.user;
    notifyListeners();
  }

  void logout() {
    _authService.logout();
    user = null;
    senhaController.clear();
    notifyListeners();
  }

  Future<void> refreshUser(StoreService api) async {
    final session = _authService.session;
    final currentUser = await api.getMe();
    if (identical(session, _authService.session)) {
      user = currentUser;
      notifyListeners();
    }
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
