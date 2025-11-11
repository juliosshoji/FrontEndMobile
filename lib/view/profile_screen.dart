import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Lê o AuthService do contexto
    final auth = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(auth.currentUser?.name ?? 'Usuário'),
            accountEmail: Text(auth.currentUser?.document ?? 'Não logado'),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 50),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar meus dados'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Alterar senha'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Gerenciar assinaturas'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Sair', style: TextStyle(color: Colors.red)),
            onTap: () {
              // CORREÇÃO: Usa o serviço lido do contexto
              auth.logout();
              Navigator.of(context)
                  .popUntil((route) => route.isFirst); // Volta para a tela inicial
            },
          ),
        ],
      ),
    );
  }
}