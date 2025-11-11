import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:helloworld/controller/api_constants.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/model/review_model.dart';

class RestProvider {
  final http.Client _client = http.Client();
  final Map<String, String> _headers = {'Content-Type': 'application/json'};


  Future<Customer> getCustomer(String document) async {
    final uri = Uri.parse("${ApiConstants.customers}/$document");
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      return Customer.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar usuário: ${response.statusCode}');
    }
  }

  Future<void> registerCustomer(Customer customer) async {
    final uri = Uri.parse(ApiConstants.customers);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: customer.toJsonString(),
    );
    if (response.statusCode != 200) { // Backend retorna OK
      throw Exception('Falha ao cadastrar usuário: ${response.statusCode}');
    }
  }

  Future<void> addFavorite(String customerId, String providerId) async {
    // Rota do backend: PUT /v1/customers/:customer_id
    final uri = Uri.parse("${ApiConstants.customers}/$customerId"); 
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

  Future<List<Professional>> getProvidersBySpecialty(String specialty) async {
    // GET /v1/providers/specialty/:specialty
    final uri = Uri.parse("${ApiConstants.providers}/specialty/$specialty");
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Professional.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar profissionais: ${response.statusCode}');
    }
  }

  // --- Review Endpoints ---

  Future<void> postReview(Review review) async {
    final uri = Uri.parse(ApiConstants.reviews);
    final response = await _client.post(
      uri,
      headers: _headers,
      body: review.toJsonString(),
    );
    if (response.statusCode != 202) { // Backend retorna 202 Accepted
      throw Exception('Falha ao enviar avaliação: ${response.statusCode}');
    }
  }
  
  Future<List<Review>> getReviewsByProvider(String providerId) async {
    // GET /v1/reviews/:option/:id
    final uri = Uri.parse("${ApiConstants.reviews}/provider/$providerId");
    final response = await _client.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar avaliações: ${response.statusCode}');
    }
  }
}