import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/provider/rest_provider.dart';

class ProfessionalsController {
  // Recebido via construtor
  final RestProvider _api;

  ProfessionalsController({required RestProvider api}) : _api = api;

  String _mapCategoryToBackend(String uiCategory) {
    String category = uiCategory.toUpperCase();
    switch (category) {
      case 'ELETRICISTA':
        return 'ELETRICIAN';
      case 'JARDINEIRO':
        return 'GARDENER';
      case 'COZINHEIRO':
        return 'COOK';
      default:
        // Retorna um valor padrão ou lança um erro
        return 'ELETRICIAN';
    }
  }

  Future<List<Professional>> fetchProfessionalsByCategory(String category) async {
    String backendCategory = _mapCategoryToBackend(category);
    // Usa o _api injetado
    return _api.getProvidersBySpecialty(backendCategory);
  }

  Future<void> addFavorite(String customerId, String providerId) async {
    // Chama o método já existente no RestProvider
    await _api.addFavorite(customerId, providerId);
  }

  Future<List<Professional>> fetchFavorites() async {
    return await _api.getFavorites();
  }
}