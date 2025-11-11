import 'package:flutter/material.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/provider/rest_provider.dart';

class AuthService extends ChangeNotifier {
  final RestProvider _api;
  Customer? _currentUser;
  bool _isLoggedIn = false;

  AuthService({required RestProvider api}) : _api = api;

  Customer? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(String document, String password) async {
    try {
      // 1. Busca o cliente no backend usando o documento
      final customer = await _api.getCustomer(document);

      // 2. Compara a senha fornecida com a senha retornada pela API
      if (customer.password == password) {
        // 3. Se as senhas correspondem, atualiza o estado de login
        _currentUser = customer;
        _isLoggedIn = true;
        notifyListeners(); // Notifica os widgets que estão ouvindo
      } else {
        // Lança um erro se a senha estiver incorreta
        throw Exception('Senha incorreta.');
      }
    } catch (e) {
      // Repassa o erro para a UI tratar (ex: usuário não encontrado, senha inválida.)
      throw Exception('Usuário não encontrado ou senha inválida.');
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}