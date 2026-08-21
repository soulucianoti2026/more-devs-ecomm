import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/recover/pages/recover_page.dart';
import 'package:more_devs_do_zero/features/signup/pages/signup_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    LoginPage.route: (context) =>  LoginPage(),
    SignupPage.route: (context) => const SignupPage(),
    RecoverPage.route: (context) => const RecoverPage(),
  };
}
