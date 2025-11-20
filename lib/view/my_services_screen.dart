// lib/view/my_services_screen.dart
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
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().refreshUser();
    });
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final currentUser = authService.currentUser;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => authService.refreshUser(),
              )
            ],
          ),
          body: services.isEmpty
              ? const Center(
                  child: Text('Nenhum serviço encontrado no histórico.'),
                )
              : ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[services.length - 1 - index];
                    final isEvaluated = service.reviewId.isNotEmpty;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: context
                          .read<RestProvider>()
                          .getProviderBasicInfo(service.providerDocument),
                      builder: (context, snapshot) {
                        String providerName = 'Carregando...';
                        if (snapshot.connectionState == ConnectionState.done) {
                           if (snapshot.hasData) {
                              providerName = snapshot.data?['name'] ?? 'Prestador';
                           } else {
                              providerName = 'Prestador não encontrado';
                           }
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isEvaluated ? Colors.green : Colors.orange,
                              child: Icon(
                                isEvaluated ? Icons.check : Icons.history,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(providerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Data: ${_formatDate(service.serviceDate)}'),
                            trailing: ElevatedButton(
                              onPressed: isEvaluated
                                  ? null
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
                                        authService.refreshUser();
                                      });
                                    },
                              child: Text(isEvaluated ? 'Avaliado' : 'Avaliar'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}