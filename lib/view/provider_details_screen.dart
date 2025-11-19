import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/view/evaluation_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- NOVO IMPORT

class ProviderDetailsScreen extends StatelessWidget {
  final Professional professional;

  const ProviderDetailsScreen({Key? key, required this.professional})
      : super(key: key);

  // Função helper para verificar o login e mostrar mensagem
  void _handleAction(BuildContext context, VoidCallback onLoggedIn) {
    final authService = context.read<AuthService>();

    if (authService.isLoggedIn) {
      onLoggedIn();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado para realizar esta ação.'),
          backgroundColor: Colors.red,
        ),
      );
      // Opcional: redirecionar para a tela de login
      // Navigator.pushNamed(context, '/login');
    }
  }

  // NOVO: Função para lançar o aplicativo de contato (Telefone ou WhatsApp)
  void _launchContact(BuildContext context) async {
    final String contactAddress = professional.contactAddress;
    final String contactType = professional.contactType;
    
    String url;
    Uri uri;

    if (contactType.toUpperCase() == 'PHONE') {
      // Abre o discador para telefone
      url = 'tel:$contactAddress';
    } else if (contactType.toUpperCase() == 'EMAIL') {
      // Abre o cliente de e-mail
      url = 'mailto:$contactAddress';
    } else {
      // Fallback: Tenta abrir como WhatsApp (pode ser o caso do 'PHONE' ser um número de WhatsApp)
      url = 'https://wa.me/$contactAddress';
    }
    
    uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o contato: $contactAddress (Tipo: $contactType)')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Opcional: Usar context.watch para reconstruir o ícone de favorito ao logar/deslogar
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(professional.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border), // Lógica de ícone preenchido/vazio aqui
            onPressed: () {
              _handleAction(context, () async {
                // Lógica para FAVORITAR o profissional aqui
                final customer = context.read<AuthService>().currentUser;
                if (customer == null) return; // Segurança extra

                final controller = context.read<ProfessionalsController>();
                final providerId = professional.document;
                final customerId = customer.document;

                try {
                  await controller.addFavorite(customerId, providerId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profissional adicionado aos favoritos!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao favoritar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(professional.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(professional.specialty, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Contatar'),
              onPressed: () {
                _handleAction(context, () {
                  // Lógica para CONTATAR o profissional (chamar função _launchContact)
                  _launchContact(context); // <-- CHAMADA ATUALIZADA
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Deixar uma Avaliação'),
              onPressed: () {
                _handleAction(context, () {
                  // Lógica para AVALIAR
                  print('Ação: Avaliar profissional');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EvaluationScreen(
                        professionalName: professional.name,
                        providerId: professional.document,
                      ),
                    ),
                  );
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const Divider(height: 40),
            Text('Avaliações', style: Theme.of(context).textTheme.titleLarge),
            // Aqui você pode adicionar a lista de avaliações existentes
          ],
        ),
      ),
    );
  }
}