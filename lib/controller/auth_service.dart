import 'package:flutter/material.dart';
import 'package:helloworld/model/customer_model.dart';
import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/provider/rest_provider.dart';
import 'package:crypto/crypto.dart'; 
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final RestProvider _api;
  Customer? _currentUser;
  bool _isLoggedIn = false;

  AuthService({required RestProvider api}) : _api = api;

  Customer? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

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

  Future<void> refreshUser() async {
    if (_currentUser != null) {
      try {
        final updatedCustomer = await _api.getCustomer(_currentUser!.document);
        _currentUser = updatedCustomer;
        notifyListeners(); 
      } catch (e) {
        print("Erro ao atualizar dados do usuário: $e");
      }
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _api.updateCustomer(customer);
    _currentUser = customer;
    _api.currentCustomer = customer;
    notifyListeners();
  }

  Future<void> deleteCustomer(String document) async {
    await _api.deleteCustomer(document);
    logout();
  }

  Future<void> deleteProvider(String document) async {
    await _api.deleteProvider(document);
    logout();
  }
}