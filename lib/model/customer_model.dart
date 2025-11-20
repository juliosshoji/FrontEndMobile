import 'dart:convert';

class ServiceDone {
  final String providerDocument;
  final String serviceDate;
  final String reviewId;

  ServiceDone({
    required this.providerDocument,
    required this.serviceDate,
    required this.reviewId,
  });

  factory ServiceDone.fromJson(Map<String, dynamic> json) {
    return ServiceDone(
      providerDocument: json['provider_document'] ?? '',
      serviceDate: json['service_date'] ?? '',
      reviewId: json['review_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_document': providerDocument,
      'service_date': serviceDate,
      'review_id': reviewId,
    };
  }
}

class Customer {
  final String document;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String birthDate;
  // Nova lista de serviços
  final List<ServiceDone> servicesDone;

  Customer({
    required this.document,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.birthDate,
    this.servicesDone = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    var list = json['services_done'] as List<dynamic>? ?? [];
    List<ServiceDone> servicesList =
        list.map((i) => ServiceDone.fromJson(i)).toList();

    return Customer(
      document: json['document'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      birthDate: json['birthday'],
      servicesDone: servicesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document': document,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'birthday': birthDate,
      // O backend pode ou não esperar esse campo no update, 
      // mas é bom tê-lo caso precise reenviar
      'services_done': servicesDone.map((s) => s.toJson()).toList(),
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}