import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/view/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _deleteAccount(BuildContext context) async {
    final authService = context.read<AuthService>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
        final document = authService.currentUser!.document;
        await authService.deleteCustomer(document);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Lê o AuthService do contexto
    final auth = context.watch<AuthService>();
    final userName = auth.currentUser?.name ?? 'Usuário';
    final userDocument = auth.currentUser?.document ?? 'Não logado';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userDocument),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 50),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar meus dados'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Alterar senha'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Gerenciar assinaturas'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Excluir conta', style: TextStyle(color: Colors.red)),
            onTap: () => _deleteAccount(context),
          ),
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