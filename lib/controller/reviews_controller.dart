import 'package:helloworld/model/review_model.dart';
import 'package:helloworld/provider/rest_provider.dart';

class ReviewsController {
  final RestProvider _api;

  ReviewsController({required RestProvider api}) : _api = api;

  Future<List<Review>> fetchReviews(String professionalId) async {
    
    final reviewsWithoutNames = await _api.getReviewsByProvider(professionalId);

    final List<Future<Review>> populatedReviewsFutures =
        reviewsWithoutNames.map((review) async {
      try {
        final customer = await _api.getCustomer(review.customerId);

        return review.copyWith(customerName: customer.name);
      } catch (e) {
        return review.copyWith(customerName: 'Usuário Anônimo');
      }
    }).toList();

    final populatedReviews = await Future.wait(populatedReviewsFutures);

    return populatedReviews;
  }
}