import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap; // ← AJOUTÉ

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap, // ← AJOUTÉ
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // ← AJOUTÉ pour détecter le clic
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF555555),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}