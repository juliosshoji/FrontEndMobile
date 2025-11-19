// lib/model/customer_model.dart
import 'dart:convert';

// Renomeado de 'User' para 'Customer' para corresponder ao backend
class Customer {
  final String document;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String birthDate; // Adicionado

  Customer({
    required this.document,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.birthDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      document: json['document'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      birthDate: json['birthday'],
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
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}
