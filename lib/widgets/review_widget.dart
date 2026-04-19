import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review_model.dart';
import '../providers/reviews_provider.dart';

/// Widget pour ajouter ou modifier un avis sur un livre
class ReviewFormDialog extends StatefulWidget {
  final String bookId;
  final String userId;
  final String userName;
  final ReviewModel? existingReview;

  const ReviewFormDialog({
    super.key,
    required this.bookId,
    required this.userId,
    required this.userName,
    this.existingReview,
  });

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  late double _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Si on modifie un avis existant, pré-remplir les champs
    _rating = widget.existingReview?.rating ?? 3.0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Fonction pour soumettre l'avis
  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    final reviewsProvider = Provider.of<ReviewsProvider>(
      context,
      listen: false,
    );

    final comment = _commentController.text.trim();

    try {
      if (widget.existingReview != null) {
        // Modifier l'avis existant
        await reviewsProvider.updateReview(
          widget.existingReview!.id,
          _rating,
          comment,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avis modifié avec succès.')),
        );
      } else {
        // Créer un nouvel avis
        final newReview = ReviewModel(
          id: '',
          bookId: widget.bookId,
          userId: widget.userId,
          userName: widget.userName,
          rating: _rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        await reviewsProvider.addReview(newReview);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avis ajouté avec succès.')),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Une erreur est survenue lors de l\'enregistrement de l\'avis.',
          ),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingReview != null
            ? 'Modifier votre avis'
            : 'Ajouter un avis',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section des étoiles - noter le livre
            const SizedBox(height: 16),
            const Text(
              'Votre note',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() => _rating = (index + 1).toDouble());
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '$_rating étoile${_rating > 1 ? 's' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),

            // Section du commentaire
            const SizedBox(height: 20),
            const Text(
              'Votre avis (optionnel)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre opinion sur ce livre... (facultatif)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                counterText: '${_commentController.text.length}/500',
              ),
              maxLength: 500,
              onChanged: (_) => setState(() {}), // Rafraîchir le compteur
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Widget pour afficher un avis
class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom et étoiles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Afficher les étoiles
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu d'options (si c'est l'utilisateur courant)
                if (isCurrentUser)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Modifier'),
                        onTap: onEdit,
                      ),
                      PopupMenuItem(
                        child: const Text('Supprimer'),
                        onTap: onDelete,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Commentaire
            Text(
              review.comment.trim().isEmpty
                  ? 'Aucun commentaire'
                  : review.comment,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            // Date
            Text(
              'Le ${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher la liste des avis d'un livre avec la moyenne
class ReviewsList extends StatefulWidget {
  final String bookId;
  final String userId;
  final String userName;

  const ReviewsList({
    super.key,
    required this.bookId,
    required this.userId,
    required this.userName,
  });

  @override
  State<ReviewsList> createState() => _ReviewsListState();
}

class _ReviewsListState extends State<ReviewsList> {
  @override
  void initState() {
    super.initState();
    // Charger les avis et les notes du livre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reviewsProvider = Provider.of<ReviewsProvider>(
        context,
        listen: false,
      );
      reviewsProvider.loadBookReviews(widget.bookId);
      reviewsProvider.loadBookRatings(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, reviewsProvider, _) {
        return Column(
          children: [
            // Section - Note moyenne et nombre d'avis
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notes et avis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              reviewsProvider.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      index <
                                              reviewsProvider.averageRating
                                                  .round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${reviewsProvider.reviewCount} avis',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bouton pour ajouter un avis
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReviewFormDialog(
                          bookId: widget.bookId,
                          userId: widget.userId,
                          userName: widget.userName,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Liste des avis
            if (reviewsProvider.bookReviews.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Aucun avis pour le moment',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewsProvider.bookReviews.length,
                itemBuilder: (context, index) {
                  final review = reviewsProvider.bookReviews[index];
                  final isCurrentUser = review.userId == widget.userId;

                  return ReviewCard(
                    review: review,
                    isCurrentUser: isCurrentUser,
                    onEdit: isCurrentUser
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => ReviewFormDialog(
                                bookId: widget.bookId,
                                userId: widget.userId,
                                userName: widget.userName,
                                existingReview: review,
                              ),
                            );
                          }
                        : null,
                    onDelete: isCurrentUser
                        ? () {
                            reviewsProvider.deleteReview(review.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avis supprimé')),
                            );
                          }
                        : null,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
