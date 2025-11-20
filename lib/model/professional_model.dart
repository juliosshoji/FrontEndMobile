import 'dart:convert';

class Professional {
  final String document;
  final String name;
  final String birthday;
  final List<String> specialties;
  final String contactType;
  final String contactAddress;
  final String? profilePhoto;

  Professional({
    required this.document,
    required this.name,
    required this.birthday,
    required this.specialties,
    required this.contactType,
    required this.contactAddress,
    this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'document': document,
      'name': name,
      'birthday': birthday,
      'specialty': specialties, 
      'contact_type': contactType,
      'contact_address': contactAddress,
      'profile_photo': profilePhoto
    };
  }
  
  String toJsonString() => json.encode(toJson());

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      document: json['document'] ?? '',
      name: json['name'] ?? '',
      birthday: json['birthday'] ?? '',
      specialties: json['specialty'] != null ? List<String>.from(json['specialty']) : [],
      contactType: json['contact_type'] ?? '',
      contactAddress: json['contact_address'] ?? '',
      profilePhoto: json['profile_photo'] ?? '',
    );
  }

  // Helper para obter a primeira especialidade (para UI)
  String get specialty => specialties.isNotEmpty ? specialties.first : 'N/A';
  
  // Helper para obter o contato (para UI)
  String get contact => contactAddress;
}
