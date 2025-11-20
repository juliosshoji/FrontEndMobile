import 'package:helloworld/model/professional_model.dart';
import 'package:helloworld/provider/rest_provider.dart';

class ProfessionalsController {
  final RestProvider _api;

  ProfessionalsController({required RestProvider api}) : _api = api;

  String? _mapCategoryToBackend(String uiCategory) {
    String category = uiCategory.toUpperCase();
    switch (category) {
      case 'ELETRICISTA':
        return 'ELETRICIAN';
      case 'JARDINEIRO':
        return 'GARDENER';
      case 'COZINHEIRO':
        return 'COOK';
      case 'ENCANADOR':
        return null;
      case 'DIARISTA':
      case 'PINTOR':
      case 'OUTRO':
      case 'TODOS':
        return null;
      default:
        return null;
    }
  }

  Future<List<Professional>> fetchProfessionalsByCategory(String category) async {
    if (category.toUpperCase() == 'TODOS') {
      return _fetchAllProfessionals();
    }

    String? backendCategory = _mapCategoryToBackend(category);
    
    if (backendCategory == null) {
      return _fetchAllProfessionals();
    }

    return _api.getProvidersBySpecialty(backendCategory);
  }

  Future<List<Professional>> _fetchAllProfessionals() async {
    final specialties = ['ELETRICIAN', 'GARDENER', 'COOK'];
    final List<Professional> allProfessionals = [];
    final Set<String> seenDocuments = {};
    for (var specialty in specialties) {
      try {
        final professionals = await _api.getProvidersBySpecialty(specialty);
        for (var professional in professionals) {
          if (!seenDocuments.contains(professional.document)) {
            seenDocuments.add(professional.document);
            allProfessionals.add(professional);
          }
        }
      } catch (e) {
        continue;
      }
    }

    return allProfessionals;
  }

  Future<void> addFavorite(String customerId, String providerId) async {
    await _api.addFavorite(customerId, providerId);
  }

  Future<List<Professional>> fetchFavorites() async {
    return await _api.getFavorites();
  }
}