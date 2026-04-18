import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/users_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user?.isAdmin != true) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Acces refuse\nVous devez etre administrateur',
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
        body: const TabBarView(children: [UsersTab(), BooksTab()]),
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

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
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
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
              if (nameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez remplir tous les champs (mdp > 6)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await context.read<UsersProvider>().createMember(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur cree avec succes'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
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

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier utilisateur'),
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
              await context.read<UsersProvider>().updateUser(
                uid: user.uid,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur modifie')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${user.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<UsersProvider>().deleteUser(user.uid);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name} supprime')),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditUserDialog(context, user);
                      } else if (value == 'toggle_admin') {
                        if (user.isAdmin) {
                          await usersProvider.demoteFromAdmin(user.uid);
                        } else {
                          await usersProvider.promoteToAdmin(user.uid);
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(context, user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Modifier'),
                      ),
                      PopupMenuItem(
                        value: 'toggle_admin',
                        child: Text(
                          user.isAdmin ? 'Retirer admin' : 'Promouvoir admin',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Supprimer'),
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

class BooksTab extends StatefulWidget {
  const BooksTab({super.key});

  @override
  State<BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadBooks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<XFile?> _pickBookImage() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 700,
    );
  }

  void _showEditBookDialog(BuildContext context, BookModel book) {
    final titleCtrl = TextEditingController(text: book.title);
    final authorCtrl = TextEditingController(text: book.author);
    final genreCtrl = TextEditingController(text: book.genre);
    XFile? selectedCover;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Modifier le livre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: authorCtrl,
                  decoration: const InputDecoration(labelText: 'Auteur'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: genreCtrl,
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Image du livre',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _pickBookImage();
                        if (picked != null) {
                          setDialogState(() {
                            selectedCover = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Choisir image'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCover != null
                            ? 'Nouvelle image sélectionnée'
                            : (book.coverUrl?.isNotEmpty == true
                                  ? 'Image actuelle conservée'
                                  : 'Aucune image'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (book.coverUrl?.isNotEmpty == true && selectedCover == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildBookCover(
                      coverUrl: book.coverUrl,
                      width: 84,
                      height: 110,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    authorCtrl.text.trim().isEmpty ||
                    genreCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await context.read<CatalogueProvider>().updateBook(
                    bookId: book.id,
                    title: titleCtrl.text.trim(),
                    author: authorCtrl.text.trim(),
                    genre: genreCtrl.text.trim(),
                    coverImage: selectedCover,
                  );

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Livre modifie avec succes'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Echec modification/upload: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteBookDialog(BuildContext context, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer "${book.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<CatalogueProvider>().deleteBook(book.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${book.title}" supprime'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    _titleController.clear();
    _authorController.clear();
    _genreController.clear();
    XFile? selectedCover;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter un livre'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(labelText: 'Auteur'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _genreController,
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Image du livre (optionnel)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _pickBookImage();
                        if (picked != null) {
                          setDialogState(() {
                            selectedCover = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Choisir image'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedCover != null
                            ? 'Image sélectionnée'
                            : 'Aucune image',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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

                try {
                  await context.read<CatalogueProvider>().addBook(
                    title: _titleController.text.trim(),
                    author: _authorController.text.trim(),
                    genre: _genreController.text.trim(),
                    coverImage: selectedCover,
                  );

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Livre ajoute avec succes'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Echec ajout/upload: $e'),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<CatalogueProvider>();

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
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 44,
                        height: 60,
                        child: (book.coverUrl != null && book.coverUrl!.isNotEmpty)
                            ? _buildBookCover(
                                coverUrl: book.coverUrl,
                                width: 44,
                                height: 60,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: book.isAvailable
                                        ? [
                                            const Color(0xFF667eea),
                                            const Color(0xFF764ba2),
                                          ]
                                        : [
                                            Colors.grey.shade400,
                                            Colors.grey.shade600,
                                          ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_book,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.author),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                book.genre,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: book.isAvailable
                                    ? const Color(0xFF27AE60).withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                book.isAvailable ? 'Disponible' : 'Prêté',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: book.isAvailable
                                      ? const Color(0xFF27AE60)
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditBookDialog(context, book);
                        } else if (value == 'toggle') {
                          await context
                              .read<CatalogueProvider>()
                              .toggleBookAvailability(
                                book.id,
                                !book.isAvailable,
                              );
                        } else if (value == 'delete') {
                          _showDeleteBookDialog(context, book);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Color(0xFF2C3E50)),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                book.isAvailable
                                    ? Icons.lock_outline
                                    : Icons.lock_open,
                                size: 18,
                                color: book.isAvailable
                                    ? Colors.orange
                                    : const Color(0xFF27AE60),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                book.isAvailable
                                    ? 'Marquer prêté'
                                    : 'Marquer disponible',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBookCover({
    required String? coverUrl,
    required double width,
    required double height,
  }) {
    if (coverUrl == null || coverUrl.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      );
    }

    final bytes = _decodeDataUrl(coverUrl);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      coverUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade200,
      ),
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
