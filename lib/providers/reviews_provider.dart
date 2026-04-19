import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewsProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  // Liste des avis d'un livre
  List<ReviewModel> _bookReviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ReviewModel> get bookReviews => _bookReviews;
  double get averageRating => _averageRating;
  int get reviewCount => _reviewCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ========== CHARGER LES AVIS D'UN LIVRE ==========
  void loadBookReviews(String bookId) {
    _reviewService.getBookReviews(bookId).listen(
      (reviews) {
        _bookReviews = reviews;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Erreur lors du chargement des avis';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ========== CHARGER LES INFOS D'UN LIVRE (MOYENNE ET NOMBRE D'AVIS) ==========
  Future<void> loadBookRatings(String bookId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final average = await _reviewService.getAverageRating(bookId);
      final count = await _reviewService.getReviewCount(bookId);

      _averageRating = average;
      _reviewCount = count;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des notes';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== AJOUTER UN AVIS ==========
  Future<void> addReview(ReviewModel review) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _reviewService.addReview(review);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de l\'avis';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== VÉRIFIER SI L'UTILISATEUR A DÉJÀ COMMENTÉ ==========
  Future<ReviewModel?> getUserReviewForBook(
      String bookId, String userId) async {
    try {
      return await _reviewService.getUserReviewForBook(bookId, userId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération de l\'avis';
      return null;
    }
  }

  // ========== MODIFIER UN AVIS ==========
  Future<void> updateReview(
      String reviewId, double rating, String comment) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _reviewService.updateReview(reviewId, rating, comment);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la modification de l\'avis';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== SUPPRIMER UN AVIS ==========
  Future<void> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _reviewService.deleteReview(reviewId);

      _bookReviews.removeWhere((review) => review.id == reviewId);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de l\'avis';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
