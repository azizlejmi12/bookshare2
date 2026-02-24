import 'package:flutter/material.dart';

// Widget pour UNE carte livre (utilisé partout)
class BookCard extends StatelessWidget {
  final String title;      // Titre du livre
  final String author;     // Nom de l'auteur
  final bool isAvailable;  // Disponible ou prêté
  final List<Color> gradientColors; // Couleurs du dégradé

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.isAvailable,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGE (dégradé)
        Container(
          width: 140,
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        const SizedBox(height: 12), // Espace
        
        // TITRE
        SizedBox(
          width: 140,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
            maxLines: 2,        // Max 2 lignes
            overflow: TextOverflow.ellipsis, // "..." si trop long
          ),
        ),
        
        const SizedBox(height: 4),
        
        // AUTEUR
        Text(
          author,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // BADGE Disponible/Prêté
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isAvailable ? const Color(0xFF27AE60) : const Color(0xFFE67E22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isAvailable ? 'Disponible' : 'Prêté',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}