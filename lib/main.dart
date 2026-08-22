import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/controllers/login_controller.dart';
import 'package:more_devs_do_zero/features/login/pages/login_page.dart';
import 'package:more_devs_do_zero/features/signup/controllers/signup_controller.dart';
import 'package:more_devs_do_zero/routes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context){
          return LoginController();
        }),
        ChangeNotifierProvider(create: (context) => SignupController()),
        ],
    builder: (context, child) {
    return MaterialApp(
    routes: AppRoutes.routes,
    initialRoute: LoginPage.route,
    );
    });
  }
}
