import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/controller/professionals_controller.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/view/evaluation_screen.dart';
import 'package:helloworld/provider/rest_provider.dart'; // <--- Import do RestProvider
import 'package:url_launcher/url_launcher.dart'; 

class ProviderDetailsScreen extends StatelessWidget {
  final Professional professional;

  const ProviderDetailsScreen({Key? key, required this.professional})
      : super(key: key);

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
    }
  }

  // Função para Contatar e Salvar no Histórico
  Future<void> _contactProvider(
      BuildContext context, String url, String contactType) async {
    final authService = context.read<AuthService>();
    final restProvider = context.read<RestProvider>();

    final Uri uri = Uri.parse(url);

    // 1. Tenta abrir o App externo (WhatsApp ou Telefone)
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // 2. Se logado, salva silenciosamente no histórico "Meus Serviços"
      if (authService.isLoggedIn && authService.currentUser != null) {
        try {
          await restProvider.addServiceHistory(
            authService.currentUser!.document,
            professional.document,
          );
          print("Serviço adicionado ao histórico com sucesso.");
        } catch (e) {
          print("Erro ao salvar histórico: $e");
          // Opcional: não mostrar erro visual para não interromper o fluxo do usuário
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o $contactType.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Prepara URLs (remove caracteres não numéricos do telefone)
    final cleanPhone = professional.contactAddress.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = "https://wa.me/55$cleanPhone"; // Assumindo +55 Brasil
    final phoneUrl = "tel:$cleanPhone";

    return Scaffold(
      appBar: AppBar(
        title: Text(professional.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              _handleAction(context, () async {
                final customer = context.read<AuthService>().currentUser;
                if (customer == null) return;

                final controller = context.read<ProfessionalsController>();
                try {
                  await controller.addFavorite(customer.document, professional.document);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profissional adicionado aos favoritos!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
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
            
            // Botão de Contato (Agora chama o _contactProvider)
            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Contatar (WhatsApp/Tel)'),
              onPressed: () {
                _handleAction(context, () {
                  // Exemplo: prioriza WhatsApp, ou você pode criar dois botões separados
                  _contactProvider(context, whatsappUrl, "WhatsApp");
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
          ],
        ),
      ),
    );
  }
}