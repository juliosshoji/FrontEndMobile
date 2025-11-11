import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:intl/intl.dart"; // Adicione a dep 'intl' ao seu pubspec.yaml
import 'package:helloworld/controller/services_controller.dart';
import 'package:helloworld/model/service_record_model.dart';

import 'evaluation_screen.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({Key? key}) : super(key: key);

  @override
  _MyServicesScreenState createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  final ServicesController _servicesController = ServicesController();
  late List<ServiceRecord> _services;

  @override
  void initState() {
    super.initState();
  _services = context.read<ServicesController>().userServices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
      ),
      body: _services.isEmpty
          ? const Center(
              child: Text('Você ainda não contatou nenhum profissional.'),
            )
          : ListView.builder(
              itemCount: _services.length,
              itemBuilder: (context, index) {
                final service = _services[index];
                final isCompleted = service.status == ServiceStatus.completed;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(service.professional.name),
                    subtitle: Text(
                        'Contato em: ${DateFormat('dd/MM/yyyy').format(service.contactDate)}'),
                    trailing: ElevatedButton(
                      onPressed: isCompleted
                          ? null
                          : () {
                              // Navega para a tela de avaliação
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EvaluationScreen(
                                      professionalName:
                                          service.professional.name, providerId: service.professional.document,),
                                ),
                              ).then((_) {
                                // Quando voltar da avaliação, marca como concluído
                                setState(() {
                                  _servicesController.completeService(service);
                                });
                              });
                            },
                      child: Text(isCompleted ? 'Avaliado' : 'Avaliar Serviço'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
