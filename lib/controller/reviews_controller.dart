import 'package:helloworld/model/review_model.dart';
import 'package:helloworld/provider/rest_provider.dart';

class ReviewsController {
  // Recebido via construtor
  final RestProvider _api;

  ReviewsController({required RestProvider api}) : _api = api;

  Future<List<Review>> fetchReviews(String professionalId) async {
    // 1. Busca a lista de avaliações (sem nomes de clientes)
    // Usa o _api injetado
    final reviewsWithoutNames = await _api.getReviewsByProvider(professionalId);

    // 2. Prepara uma lista de "tarefas" (buscas de nomes de clientes)
    final List<Future<Review>> populatedReviewsFutures =
        reviewsWithoutNames.map((review) async {
      try {
        // 3. Para cada avaliação, busca o cliente correspondente
        final customer = await _api.getCustomer(review.customerId);

        // 4. Retorna uma CÓPIA da avaliação, agora com o nome
        return review.copyWith(customerName: customer.name);
      } catch (e) {
        // Se falhar (ex: cliente deletado), retorna a avaliação original
        return review.copyWith(customerName: 'Usuário Anônimo');
      }
    }).toList();

    // 5. Executa todas as buscas de nome em paralelo e espera terminarem
    final populatedReviews = await Future.wait(populatedReviewsFutures);

    // 6. Retorna a lista completa para a UI
    return populatedReviews;
  }
}