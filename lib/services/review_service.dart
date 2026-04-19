import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== AJOUTER UN AVIS ==========
  Future<void> addReview(ReviewModel review) async {
    try {
      await _db.collection('reviews').add(review.toFirestore());
    } catch (e) {
      print('Erreur ajout avis: $e');
      rethrow;
    }
  }

  // ========== RÉCUPÉRER LES AVIS D'UN LIVRE ==========
  Stream<List<ReviewModel>> getBookReviews(String bookId) {
    return _db
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReviewModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ========== RÉCUPÉRER LA NOTE MOYENNE D'UN LIVRE ==========
  Future<double> getAverageRating(String bookId) async {
    try {
      final snapshot = await _db
          .collection('reviews')
          .where('bookId', isEqualTo: bookId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final totalRating = snapshot.docs
          .fold<double>(0.0, (sum, doc) => sum + (doc['rating'] ?? 0).toDouble());

      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Erreur calcul note moyenne: $e');
      return 0.0;
    }
  }

  // ========== RÉCUPÉRER LE NOMBRE D'AVIS ==========
  Future<int> getReviewCount(String bookId) async {
    try {
      final snapshot = await _db
          .collection('reviews')
          .where('bookId', isEqualTo: bookId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Erreur calcul nombre avis: $e');
      return 0;
    }
  }

  // ========== VÉRIFIER SI L'UTILISATEUR A DÉJÀ COMMENTÉ ==========
  Future<ReviewModel?> getUserReviewForBook(
      String bookId, String userId) async {
    try {
      final snapshot = await _db
          .collection('reviews')
          .where('bookId', isEqualTo: bookId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ReviewModel.fromFirestore(
          snapshot.docs.first.data(), snapshot.docs.first.id);
    } catch (e) {
      print('Erreur récupérer avis utilisateur: $e');
      return null;
    }
  }

  // ========== MODIFIER UN AVIS ==========
  Future<void> updateReview(
      String reviewId, double rating, String comment) async {
    try {
      await _db.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      print('Erreur modification avis: $e');
      rethrow;
    }
  }

  // ========== SUPPRIMER UN AVIS ==========
  Future<void> deleteReview(String reviewId) async {
    try {
      await _db.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      print('Erreur suppression avis: $e');
      rethrow;
    }
  }
}
