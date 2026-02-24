import 'package:flutter/material.dart';

// Widget réutilisable pour la barre de navigation du bas
class BottomNav extends StatelessWidget {
  final int currentIndex;      // Page actuelle (0, 1, 2, 3, 4)
  final Function(int) onTap;   // Action quand on clique

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,  // 5 items ou plus
      selectedItemColor: const Color(0xFF2C3E50),    // Bleu sélectionné
      unselectedItemColor: const Color(0xFF7F8C8D),  // Gris non sélectionné
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Catalogue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Emprunts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}