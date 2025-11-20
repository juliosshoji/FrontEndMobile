import 'dart:convert';

class Review {
  final String? id;
  final String title;
  final String description;
  final int rating;
  final String customerId;
  final String providerId;

  final String? customerName; 

  Review({
    this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.customerId,
    required this.providerId,
    this.customerName,
  });

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

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0).toInt(),
      customerId: json['customer_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      customerName: null,
    );
  }
}