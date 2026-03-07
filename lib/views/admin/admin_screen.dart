import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../firebase_options.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../auth/login_screen.dart';
import '../../services/firestore_service.dart';
import '../../providers/users_provider.dart';
import '../../models/user_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    // 🔍 DEBUG ADMIN CHECK
    print('╔════════════════════════════════════╗');
    print('║ DEBUG ADMIN SCREEN                 ║');
    print('╠════════════════════════════════════╣');
    print('║ user: $user');
    print('║ user?.name: ${user?.name}');
    print('║ user?.email: ${user?.email}');
    print('║ user?.isAdmin: ${user?.isAdmin}');
    print('║ user?.isAdmin.runtimeType: ${user?.isAdmin.runtimeType}');
    print('║ user?.isAdmin == true: ${user?.isAdmin == true}');
    print('║ user?.isAdmin != true: ${user?.isAdmin != true}');
    print('╚════════════════════════════════════╝');

    // Vérifie si admin
    if (user?.isAdmin != true) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Accès refusé\nVous devez être administrateur',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text('Administration'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
              Tab(icon: Icon(Icons.book), text: 'Livres'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            UsersTab(),
            BooksTab(),
          ],
        ),
      ),
    );
  }
}

// ==================== ONGLET UTILISATEURS ====================
class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  void initState() {
    super.initState();
    // Charge les utilisateurs au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

  // 🔥 NOUVEAU : Dialog pour ajouter un utilisateur
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex: Jean Dupont',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Ex: jean@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Min 6 caractères',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🔥 DÉBUT AJOUT UTILISATEUR');

              // Validation
              if (nameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs (mdp > 6 caractères)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // 🔥 CRÉE L'UTILISATEUR SANS DÉCONNECTER L'ADMIN
              // Solution : instance Firebase secondaire
              try {
                print('🔥 Création utilisateur: ${emailController.text}');

                // Créer une instance Firebase secondaire
                final secondaryApp = await Firebase.initializeApp(
                  name: 'SecondaryApp-${DateTime.now().millisecondsSinceEpoch}',
                  options: DefaultFirebaseOptions.currentPlatform,
                );
                
                final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);
                
                // Créer l'utilisateur avec l'instance secondaire
                final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                // Mettre à jour le displayName
                await userCredential.user?.updateDisplayName(nameController.text.trim());

                // Sauvegarder dans Firestore
                final userModel = UserModel(
                  uid: userCredential.user!.uid,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  createdAt: DateTime.now(),
                  isAdmin: false,
                );
                
                await FirestoreService().saveUser(userModel);

                // Nettoyer l'instance secondaire
                await secondaryApp.delete();

                print('✅ Utilisateur créé avec succès');
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Utilisateur créé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('❌ ERREUR: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  // 🔥 NOUVEAU : Dialog pour modifier un utilisateur
  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final firestore = FirestoreService();
              await firestore.updateUser(
                uid: user.uid,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Utilisateur modifié')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // 🔥 NOUVEAU : Dialog pour confirmer suppression
  void _showDeleteConfirmDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${user.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final firestore = FirestoreService();
              await firestore.deleteUser(user.uid);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🗑️ ${user.name} supprimé')),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, usersProvider, child) {
        if (usersProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (usersProvider.error != null) {
          return Center(child: Text('Erreur: ${usersProvider.error}'));
        }
      
        // 🔥 NOUVEAU : Scaffold avec FloatingActionButton
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddUserDialog(context),
            backgroundColor: const Color(0xFF2C3E50),
            child: const Icon(Icons.person_add),
          ),
          body: ListView.builder(
            itemCount: usersProvider.users.length,
            itemBuilder: (context, index) {
              final user = usersProvider.users[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin 
                      ? const Color(0xFFE74C3C) 
                      : const Color(0xFF2C3E50),
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Admin
                      if (user.isAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      
                      const SizedBox(width: 8),
                      
                      // 🔥 NOUVEAU : Menu avec 3 options (Modifier, Admin/Retirer, Supprimer)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditUserDialog(context, user);
                          } else if (value == 'toggle_admin') {
                            if (user.isAdmin) {
                              await usersProvider.demoteFromAdmin(user.uid);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${user.name} n\'est plus admin'),
                                  ),
                                );
                              }
                            } else {
                              await usersProvider.promoteToAdmin(user.uid);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${user.name} est maintenant admin'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(context, user);
                          }
                        },
                        itemBuilder: (context) => [
                          // 🔥 Option Modifier
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          // Option Promouvoir/Retirer admin
                          PopupMenuItem(
                            value: 'toggle_admin',
                            child: Row(
                              children: [
                                Icon(
                                  user.isAdmin 
                                    ? Icons.remove_moderator 
                                    : Icons.add_moderator,
                                  color: user.isAdmin ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  user.isAdmin 
                                    ? 'Retirer admin' 
                                    : 'Promouvoir admin',
                                ),
                              ],
                            ),
                          ),
                          // 🔥 Option Supprimer
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ==================== ONGLET LIVRES (inchangé) ====================
class BooksTab extends StatefulWidget {
  const BooksTab({super.key});

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  void _showAddBookDialog(BuildContext context) {
    _titleController.clear();
    _authorController.clear();
    _genreController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un livre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'Ex: Le Petit Prince',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Auteur',
                hintText: 'Ex: Saint-Exupéry',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Genre',
                hintText: 'Ex: Roman',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.trim().isEmpty ||
                  _authorController.text.trim().isEmpty ||
                  _genreController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final firestore = FirestoreService();
              await firestore.addBook(
                title: _titleController.text.trim(),
                author: _authorController.text.trim(),
                genre: _genreController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Livre ajouté avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookDialog(context),
        backgroundColor: const Color(0xFF2C3E50),
        child: const Icon(Icons.add),
      ),
      body: bookProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return ListTile(
                  leading: Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: book.isAvailable
                            ? [Colors.blue, Colors.purple]
                            : [Colors.grey, Colors.grey],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(book.title),
                  subtitle: Text('${book.author} • ${book.genre}'),
                  trailing: Switch(
                    value: book.isAvailable,
                    onChanged: (value) async {
                      final firestore = FirestoreService();
                      await firestore.toggleBookAvailability(book.id, value);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value 
                              ? '✅ "${book.title}" est maintenant disponible'
                              : '❌ "${book.title}" est maintenant indisponible',
                          ),
                          backgroundColor: value ? Colors.green : Colors.orange,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}