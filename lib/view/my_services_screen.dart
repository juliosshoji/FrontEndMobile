import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:intl/intl.dart";
import 'package:helloworld/controller/auth_service.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/provider/rest_provider.dart';
import 'evaluation_screen.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({Key? key}) : super(key: key);

  @override
  _MyServicesScreenState createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  
  // Função para formatar a data string do Go (provavelmente ISO ou simples)
  String _formatDate(String dateStr) {
    try {
      // Ajuste o parse conforme o formato que seu Go envia. 
      // Se for ISO 8601 (ex: 2025-11-19T...):
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr; // Retorna original se falhar
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o usuário logado
    final authService = context.watch<AuthService>();
    final currentUser = authService.currentUser;

    // Verificação de segurança extra (caso acesse a rota diretamente)
    if (!authService.isLoggedIn || currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Serviços')),
        body: const Center(child: Text('Faça login para ver seus serviços.')),
      );
    }

    final List<ServiceDone> services = currentUser.servicesDone;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
      ),
      body: services.isEmpty
          ? const Center(
              child: Text('Você ainda não contratou nenhum serviço.'),
            )
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final isEvaluated = service.reviewId.isNotEmpty;

                // Usamos FutureBuilder para buscar o nome do profissional
                // baseado no providerDocument salvo no histórico
                return FutureBuilder<Map<String, dynamic>>(
                  future: context
                      .read<RestProvider>()
                      .getProviderBasicInfo(service.providerDocument),
                  builder: (context, snapshot) {
                    String providerName = 'Carregando...';
                    if (snapshot.hasData) {
                      providerName = snapshot.data?['name'] ?? 'Desconhecido';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(isEvaluated ? Icons.check : Icons.build),
                          backgroundColor: isEvaluated ? Colors.green : null,
                          foregroundColor: isEvaluated ? Colors.white : null,
                        ),
                        title: Text(providerName),
                        subtitle: Text(
                            'Data: ${_formatDate(service.serviceDate)}'),
                        trailing: ElevatedButton(
                          onPressed: isEvaluated
                              ? null // Desabilita se já tem review_id
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EvaluationScreen(
                                        professionalName: providerName,
                                        providerId: service.providerDocument,
                                      ),
                                    ),
                                  ).then((_) {
                                    // Opcional: Recarregar dados do usuário após avaliação
                                    // para atualizar o status do botão
                                  });
                                },
                          child: Text(isEvaluated ? 'Avaliado' : 'Avaliar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEvaluated
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}