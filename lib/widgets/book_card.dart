import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// Widget pour UNE carte livre (utilisé partout)
class BookCard extends StatelessWidget {
  final String title;      // Titre du livre
  final String author;     // Nom de l'auteur
  final bool isAvailable;  // Disponible ou prêté
  final String? coverUrl;  // URL de la couverture
  final List<Color> gradientColors; // Couleurs du dégradé

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.isAvailable,
    this.coverUrl,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGE (photo réseau si disponible, sinon dégradé)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 140,
            height: 200,
            child: (coverUrl != null && coverUrl!.isNotEmpty)
                ? _buildCoverImage(coverUrl!)
                : _buildGradientPlaceholder(),
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

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCoverImage(String source) {
    final bytes = _decodeDataUrl(source);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
      );
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
    );
  }

  Uint8List? _decodeDataUrl(String value) {
    if (!value.startsWith('data:image')) return null;
    final commaIndex = value.indexOf(',');
    if (commaIndex == -1 || commaIndex == value.length - 1) return null;

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}