import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:helloworld/controller/api_constants.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/model/review_model.dart';

class RestProvider {
  final http.Client _client = http.Client();
  
  String? _token;
  String? _userType;
  String? _document;

  Customer? _currentCustomer;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
      headers['user-type'] = _userType ?? '';
      headers['document'] = _document ?? '';
    }
    return headers;
  }

  set currentCustomer(Customer customer) {
    _currentCustomer = customer;
  }
  
  Future<void> login(String document, String passwordHash) async {
    final uri = Uri.parse("${ApiConstants.BASE_URL}/login"); 
    
    final response = await _client.post(
      uri,
      headers: _headers,
      body: json.encode({
        'document': document,
        'password': passwordHash
      }),
    );

    if (response.statusCode == 202) {
      final data = json.decode(response.body);
      _token = data['token'];
    } else {
      throw Exception('Falha no login: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Customer> getCustomer(String document) async {
    _document = document;
    _userType = 'customer';

    final uri = Uri.parse("${ApiConstants.customers}/$document");
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar usuário: ${response.statusCode}');
    }
  }

  Future<List<Professional>> getFavorites() async {
    _document = _currentCustomer?.document ?? '';
    _userType = 'customer';

    final uri = Uri.parse("${ApiConstants.customers}/favorite/$_document");
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Professional.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar favoritos: ${response.statusCode}');
    }
  }

  Future<void> registerCustomer(Customer customer) async {
    final uri = Uri.parse(ApiConstants.customers);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: customer.toJsonString(),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao cadastrar usuário: ${response.statusCode}');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    _document = customer.document;
    _userType = 'customer';
    final uri = Uri.parse("${ApiConstants.customers}/${customer.document}");
    final response = await _client.put(
      uri,
      headers: _headers,
      body: customer.toJsonString(),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar usuário: ${response.statusCode}');
    }
  }

  Future<void> deleteCustomer(String document) async {
    _document = document;
    _userType = 'customer';
    final uri = Uri.parse("${ApiConstants.customers}/$document");
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar usuário: ${response.statusCode}');
    }
  }

  Future<void> addFavorite(String customerId, String providerId) async {
    _document = customerId;
    _userType = 'customer';
    final uri = Uri.parse("${ApiConstants.customers}/favorite/$customerId"); 
    final body = json.encode({'provider_id': providerId});
    final response = await _client.put(uri, headers: _headers, body: body);
    if (response.statusCode != 200) {
      throw Exception('Falha ao adicionar favorito: ${response.statusCode}');
    }
  }

  // --- Professional Endpoints ---

  Future<void> registerProvider(Professional provider) async {
    final uri = Uri.parse(ApiConstants.providers);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: provider.toJsonString(),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao cadastrar provedor: ${response.statusCode}');
    }
  }

  Future<void> updateProvider(Professional provider) async {
    _document = provider.document;
    _userType = 'provider';
    final uri = Uri.parse("${ApiConstants.providers}/${provider.document}");
    final response = await _client.put(
      uri,
      headers: _headers,
      body: provider.toJsonString(),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar provedor: ${response.statusCode}');
    }
  }

  Future<void> deleteProvider(String document) async {
    _document = document;
    _userType = 'provider';
    final uri = Uri.parse("${ApiConstants.providers}/$document");
    final response = await _client.delete(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar provedor: ${response.statusCode}');
    }
  }

  Future<List<Professional>> getProvidersBySpecialty(String specialty) async {
    final uri = Uri.parse("${ApiConstants.BASE_URL}/specialty/$specialty");
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Professional.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar profissionais: ${response.statusCode}');
    }
  }

  // <--- NOVO ENDPOINT PARA ATUALIZAR FOTO DE PERFIL
  Future<void> updateProviderProfilePhoto(String document, String base64Photo) async {
    // Usamos o endpoint PUT /providers/:document para atualizar o perfil
    final uri = Uri.parse("${ApiConstants.providers}/$document");

    // Enviamos o documento e a string Base64 da foto no corpo JSON
    final response = await _client.put(
      uri,
      headers: _headers,
      body: json.encode({
        'document': document, 
        'profile_photo': base64Photo,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar foto de perfil: ${response.statusCode}');
    }
  }
  // <--- FIM DO NOVO ENDPOINT


  Future<void> postReview(Review review) async {
    final uri = Uri.parse(ApiConstants.reviews);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: review.toJsonString(),
    );
    if (response.statusCode != 202) { 
      throw Exception('Falha ao enviar avaliação: ${response.statusCode}');
    }
  }
  
  Future<List<Review>> getReviewsByProvider(String providerId) async {
    final uri = Uri.parse("${ApiConstants.reviews}/provider/$providerId");
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar avaliações: ${response.statusCode}');
    }
  }
}