import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/users_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_screen.dart';
import '../../widgets/admin/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Stream<int> _activeLoansCountStream() {
    return FirebaseFirestore.instance
        .collection('loans')
        .where('status', whereIn: ['active', 'extended'])
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  void initState() {
    super.initState();
    // Charger les données nécessaires pour afficher les statistiques
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final users = Provider.of<UsersProvider>(context, listen: false);
      final catalogue =
          Provider.of<CatalogueProvider>(context, listen: false);
      users.loadUsers();
      catalogue.loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final current = auth.currentUser;
    if (current?.isAdmin != true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: const Center(
          child: Text(
            'Accès refusé. Vous devez être administrateur.',
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final usersProvider = Provider.of<UsersProvider>(context);
    final catalogueProvider = Provider.of<CatalogueProvider>(context);

    final totalUsers = usersProvider.users.length;
    final totalBooks = catalogueProvider.books.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              int columns = 3;
              if (maxWidth < 400) {
                columns = 1;
              } else if (maxWidth < 700) {
                columns = 2;
              }

              final spacing = 12.0;
              final totalSpacing = spacing * (columns - 1);
              final cardWidth = (maxWidth - totalSpacing) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: StatsCard(
                      title: 'Utilisateurs',
                      value: totalUsers.toString(),
                      color: Colors.blueAccent,
                      icon: Icons.person,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StatsCard(
                      title: 'Livres',
                      value: totalBooks.toString(),
                      color: Colors.green,
                      icon: Icons.book,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: StreamBuilder<int>(
                      stream: _activeLoansCountStream(),
                      initialData: 0,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return StatsCard(
                          title: 'Emprunts actifs',
                          value: count.toString(),
                          color: Colors.orange,
                          icon: Icons.book_online,
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Actions rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Gérer les utilisateurs'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Gérer le catalogue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
