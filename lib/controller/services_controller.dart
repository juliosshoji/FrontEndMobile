import 'package:helloworld/model/professional_model.dart';
import '../model/service_record_model.dart';

class ServicesController {
  static final ServicesController _instance = ServicesController._internal();
  factory ServicesController() => _instance;
  ServicesController._internal();

  final List<ServiceRecord> _userServices = [];

  List<ServiceRecord> get userServices => _userServices;

  void startService(Professional professional) {
    if (!_userServices
        .any((record) => record.professional.name == professional.name)) {
      _userServices.add(ServiceRecord(
        professional: professional,
        contactDate: DateTime.now(),
      ));
    }
  }

  void completeService(ServiceRecord record) {
    record.status = ServiceStatus.completed;
  }
}
