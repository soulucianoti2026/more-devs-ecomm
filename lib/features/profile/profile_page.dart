import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/login/model/user.dart';
import 'package:more_devs_do_zero/shared/services/store_service.dart';
import 'package:more_devs_do_zero/shared/widgets/api_view.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const route = '/profile';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Minha conta')),
    body: ApiView<User>(
      load: context.read<StoreService>().getMe,
      builder: (context, user) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ListTile(title: const Text('Nome'), subtitle: Text(user.nome)),
          ListTile(title: const Text('E-mail'), subtitle: Text(user.email)),
        ],
      ),
    ),
  );
}
