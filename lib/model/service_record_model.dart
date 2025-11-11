import 'package:helloworld/model/professional_model.dart';

enum ServiceStatus { active, completed }

class ServiceRecord {
  final Professional professional;
  final DateTime contactDate;
  ServiceStatus status;

  ServiceRecord({
    required this.professional,
    required this.contactDate,
    this.status = ServiceStatus.active,
  });
}
