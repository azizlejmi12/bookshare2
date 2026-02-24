import 'package:flutter/material.dart';

// Widget pour UN item du menu profil
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;      // Icône (Icons.book, Icons.notifications...)
  final String label;       // Texte
  final bool isLogout;      // True = rouge (déconnexion)
  final VoidCallback onTap; // Action quand on clique

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.isLogout = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Icône dans un cercle coloré
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout 
                    ? const Color(0xFFFADBD8)  // Rouge clair
                    : const Color(0xFFF5F5F0), // Gris clair
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout 
                    ? const Color(0xFFE74C3C)  // Rouge
                    : const Color(0xFF2C3E50), // Bleu
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Texte
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout 
                      ? const Color(0xFFE74C3C)  // Rouge
                      : const Color(0xFF2C3E50), // Bleu
                ),
              ),
            ),
            
            // Flèche >
            Icon(
              Icons.chevron_right,
              color: isLogout 
                  ? const Color(0xFFE74C3C)
                  : const Color(0xFF7F8C8D),
            ),
          ],
        ),
      ),
    );
  }
}