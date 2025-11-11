import 'package:helloworld/model/professional_model.dart';
import '../model/service_record_model.dart';

// Usando Singleton para manter a lista de serviços durante o uso do app
class ServicesController {
  static final ServicesController _instance = ServicesController._internal();
  factory ServicesController() => _instance;
  ServicesController._internal();

  final List<ServiceRecord> _userServices = [];

  // Retorna a lista de serviços do usuário
  List<ServiceRecord> get userServices => _userServices;

  // Adiciona um novo serviço quando o usuário contata um profissional
  void startService(Professional professional) {
    // Evita adicionar o mesmo serviço várias vezes
    if (!_userServices
        .any((record) => record.professional.name == professional.name)) {
      _userServices.add(ServiceRecord(
        professional: professional,
        contactDate: DateTime.now(),
      ));
    }
  }

  // Marca um serviço como concluído (usado após a avaliação)
  void completeService(ServiceRecord record) {
    record.status = ServiceStatus.completed;
  }
}
