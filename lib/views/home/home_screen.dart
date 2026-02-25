import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_list_item.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/emprunt_card.dart';
import '../../widgets/tab_selector.dart';
import '../../widgets/profile_menu_item.dart';
import '../../widgets/message_item.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;  // Page actuelle (0 = Home)

  // Liste des 5 écrans
  final List<Widget> pages = [
    const HomeContent(),      // Page 0
    const CatalogueContent(), // Page 1
    const EmpruntsContent(),  // Page 2
    const MessagesContent(),  // Page 3
    const ProfilContent(),    // Page 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],  // Affiche la page actuelle
      bottomNavigationBar: BottomNav(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;  // Change de page
          });
        },
      ),
    );
  }
}

// ===== CONTENU DE CHAQUE PAGE =====

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(  // Pour défiler vers le bas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER BLEU =====
            Container(
              color: const Color(0xFF2C3E50),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: const [
                  SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        '📚 BookShare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.notifications, color: Colors.white),
                ],
              ),
            ),
            
            
            // ===== BARRE DE RECHERCHE =====
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search, color: Color(0xFF7F8C8D)),
                    SizedBox(width: 12),
                    Text(
                      'Rechercher un livre, auteur...',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // ===== SECTION RECOMMANDÉS =====
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                '📚 Recommandés',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            
            // Carousel horizontal
            SizedBox(
              height: 320, // Hauteur fixe pour le carousel
              child: ListView(
                scrollDirection: Axis.horizontal, // Défilement horizontal
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: const [
                  BookCard(
                    title: 'Le Petit Prince',
                    author: 'Saint-Exupéry',
                    isAvailable: true,
                    gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  SizedBox(width: 16), // Espace entre cartes
                  BookCard(
                    title: '1984',
                    author: 'George Orwell',
                    isAvailable: false,
                    gradientColors: [Color(0xFFfa709a), Color(0xFFfee140)],
                  ),
                  SizedBox(width: 16),
                  BookCard(
                    title: 'Dune',
                    author: 'Frank Herbert',
                    isAvailable: true,
                    gradientColors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                  ),
                ],
              ),
            ),
            
            // ===== SECTION NOUVEAUTÉS =====
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                '✨ Nouveautés',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            
            // Liste verticale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  BookListItem(
                    title: 'Harry Potter à l\'école des sorciers',
                    author: 'J.K. Rowling',
                    isAvailable: true,
                    gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  BookListItem(
                    title: 'Le Seigneur des Anneaux',
                    author: 'J.R.R. Tolkien',
                    isAvailable: false,
                    gradientColors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20), // Espace en bas
          ],
        ),
      ),
    );
  }
}

class CatalogueContent extends StatelessWidget {
  const CatalogueContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER BLANC =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Color(0xFF2C3E50)),
                const Text(
                  'Catalogue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Icon(Icons.search, color: Color(0xFF2C3E50)),
              ],
            ),
          ),
          
          // ===== FILTRES =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(label: 'Tous', isSelected: true),
                  CategoryChip(label: 'Roman', isSelected: false),
                  CategoryChip(label: 'Policier', isSelected: false),
                  CategoryChip(label: 'SF', isSelected: false),
                  CategoryChip(label: 'BD', isSelected: false),
                ],
              ),
            ),
          ),
          
          // ===== LISTE DES LIVRES =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                BookListItem(
                  title: 'Le Petit Prince',
                  author: 'Saint-Exupéry',
                  isAvailable: true,
                  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                BookListItem(
                  title: '1984',
                  author: 'George Orwell',
                  isAvailable: false,
                  gradientColors: [Color(0xFFfa709a), Color(0xFFfee140)],
                ),
                BookListItem(
                  title: 'Dune',
                  author: 'Frank Herbert',
                  isAvailable: true,
                  gradientColors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                ),
                BookListItem(
                  title: 'Harry Potter',
                  author: 'J.K. Rowling',
                  isAvailable: true,
                  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CHANGEMENT : StatefulWidget au lieu de StatelessWidget
// Pour gérer les onglets cliquables
class EmpruntsContent extends StatefulWidget {
  const EmpruntsContent({super.key});

  @override
  State<EmpruntsContent> createState() => _EmpruntsContentState();
}

class _EmpruntsContentState extends State<EmpruntsContent> {
  int selectedTab = 0;  // 0 = En cours, 1 = Historique

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                const SizedBox(width: 16),
                const Text(
                  'Mes Emprunts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          
          // ===== ONGLETS =====
          TabSelector(
            tabs: const ['En cours (2)', 'Historique'],
            selectedIndex: selectedTab,
            onTap: (index) {
              setState(() {
                selectedTab = index;  // Change l'onglet
              });
            },
          ),
          
          // ===== CONTENU =====
          Expanded(
            child: selectedTab == 0
                // Onglet "En cours"
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: const [
                      EmpruntCard(
                        title: 'Le Petit Prince',
                        author: 'Saint-Exupéry',
                        returnDate: '18/02/2024',
                        isUrgent: true,  // Rouge !
                        gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      EmpruntCard(
                        title: '1984',
                        author: 'George Orwell',
                        returnDate: '25/02/2024',
                        isUrgent: false,  // Vert
                        gradientColors: [Color(0xFFfa709a), Color(0xFFfee140)],
                      ),
                    ],
                  )
                // Onglet "Historique" (vide pour l'instant)
                : const Center(
                    child: Text(
                      'Aucun historique',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MessagesContent extends StatelessWidget {
  const MessagesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ),
          
          // ===== BARRE DE RECHERCHE =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 16),
                  Icon(Icons.search, color: Color(0xFF7F8C8D)),
                  SizedBox(width: 12),
                  Text(
                    'Rechercher...',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ===== LISTE DES CONVERSATIONS =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                MessageItem(
                  name: 'Marie',
                  message: 'Bonjour, le livre est disponible ?',
                  time: '10:30',
                  unreadCount: 2,  // Non lu !
                  onTap: () {},
                ),
                MessageItem(
                  name: 'Bibliothèque',
                  message: 'Votre livre doit être retourné avant le 18/02',
                  time: 'Hier',
                  isAdmin: true,  // Orange
                  onTap: () {},
                ),
                MessageItem(
                  name: 'Paul',
                  message: 'Merci pour votre aide !',
                  time: 'Lun',
                  onTap: () {},  // Lu (pas de badge)
                ),
                MessageItem(
                  name: 'Sophie',
                  message: 'À demain pour le club de lecture',
                  time: 'Dim',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilContent extends StatelessWidget {
  const ProfilContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Mon Profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ),
          
          // ===== SECTION PROFIL (avatar + infos) =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2C3E50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Nom
                const Text(
                  'Aziz Lejmi',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Email
                const Text(
                  'azizlejmi@email.com',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Badge "Membre depuis"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Membre depuis 2024',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ===== MENU =====
          ProfileMenuItem(
            icon: Icons.menu_book,
            label: 'Mes emprunts',
            onTap: () {
              // Naviguer vers Emprunts
            },
          ),
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {
              // Naviguer vers Notifications
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileMenuItem(
            icon: Icons.help_outline,
            label: 'Aide & Support',
            onTap: () {},
          ),
          ProfileMenuItem(
  icon: Icons.logout,
  label: 'Déconnexion',
  isLogout: true,
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  },
),
        ],
      ),
    );
  }
}
