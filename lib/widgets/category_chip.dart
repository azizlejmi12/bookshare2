import 'package:flutter/material.dart';

// Widget pour UNE catégorie (Tous, Roman, etc.)
// Renommé pour éviter le conflit avec FilterChip natif de Flutter
class CategoryChip extends StatelessWidget {
  final String label;      // Texte de la catégorie
  final bool isSelected;   // Sélectionnée ou non

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Couleur : bleu si sélectionné, gris sinon
        color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          // Texte blanc si sélectionné, gris foncé sinon
          color: isSelected ? Colors.white : const Color(0xFF555555),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}