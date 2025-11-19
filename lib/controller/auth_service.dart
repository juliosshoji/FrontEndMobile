import 'package:flutter/material.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/provider/rest_provider.dart';
import 'package:crypto/crypto.dart'; // Import crypto
import 'dart:convert'; // Import convert para utf8

class AuthService extends ChangeNotifier {
  final RestProvider _api;
  Customer? _currentUser;
  bool _isLoggedIn = false;

  AuthService({required RestProvider api}) : _api = api;

  Customer? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Helper para Hash SHA256
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> login(String document, String password) async {
    try {
      final passwordHash = _hashPassword(password);

      await _api.login(document, passwordHash);

     
      final customer = await _api.getCustomer(document);

      _api.currentCustomer = customer;
      _currentUser = customer;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print(e);
      throw Exception('Usuário não encontrado ou senha inválida.');
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    // Nota: Idealmente você também limparia o token no RestProvider
    notifyListeners();
  }
}