import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/users_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/loans_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_screen.dart';
import '../../widgets/admin/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final loansProvider = Provider.of<LoansProvider>(context);

    final totalUsers = usersProvider.users.length;
    final totalBooks = catalogueProvider.books.length;
    final totalLoans = loansProvider.activeLoans.length;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Utilisateurs',
                    value: totalUsers.toString(),
                    color: Colors.blueAccent,
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Livres',
                    value: totalBooks.toString(),
                    color: Colors.green,
                    icon: Icons.book,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Emprunts actifs',
                    value: totalLoans.toString(),
                    color: Colors.orange,
                    icon: Icons.book_online,
                  ),
                ),
              ],
            ),
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
