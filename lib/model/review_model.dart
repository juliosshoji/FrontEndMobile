// lib/model/review_model.dart
import 'dart:convert';

class Review {
  // Campos que vêm da API /reviews
  final String? id;
  final String title;
  final String description;
  final int rating;
  final String customerId;
  final String providerId;

  // Campo ENRIQUECIDO - Preenchido no app após buscar o cliente
  final String? customerName; 

  Review({
    this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.customerId,
    required this.providerId,
    this.customerName, // Adicionado como opcional
  });

  // Método 'copyWith' para facilitar a adição do nome do cliente
  // sem precisar criar um objeto totalmente novo
  Review copyWith({
    String? id,
    String? title,
    String? description,
    int? rating,
    String? customerId,
    String? providerId,
    String? customerName,
  }) {
    return Review(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      customerName: customerName ?? this.customerName,
    );
  }

  // toJson - Usado para ENVIAR uma nova avaliação
  // Note que 'customerName' não é incluído, pois o backend não o espera
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'title': title,
      'description': description,
      'rating': rating,
      'customer_id': customerId,
      'provider_id': providerId,
    };
  }

  String toJsonString() => json.encode(toJson());

  // fromJson - Usado para LER uma avaliação vinda do backend
  // Note que 'customerName' é nulo aqui, pois a API /reviews não o envia
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toInt(),
      customerId: json['customer_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      customerName: null, // Será preenchido depois pelo controller
    );
  }
}