import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../notifications/notifications_screen.dart';
import '../auth/login_screen.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onOpenLoansTab;

  const ProfileScreen({super.key, this.onOpenLoansTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<LoansProvider>().watchUserLoans(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;
        final loans = context.watch<LoansProvider>();
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
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

                // Section Profil
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: auth.isLoading
                            ? null
                            : () => _openProfileImageActions(user),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildProfileAvatar(user),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nom dynamique
                      Text(
                        user?.name ?? 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email dynamique
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge membre
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Membre depuis ${user?.createdAt.year ?? DateTime.now().year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Badge Admin conditionnel
                          if (user?.isAdmin == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE74C3C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Stats rapides
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: 'Emprunts actifs',
                          value: loans.activeLoans.length.toString(),
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          label: 'Historique',
                          value: loans.historyLoans.length.toString(),
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Menu
                _buildMenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Modifier mon nom',
                  onTap: () => _openEditNameDialog(context),
                ),
                _buildMenuItem(
                  icon: Icons.menu_book,
                  label: 'Mes emprunts',
                  onTap: () {
                    if (widget.onOpenLoansTab != null) {
                      widget.onOpenLoansTab!();
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Utilisez l\'onglet Emprunts en bas pour gérer vos livres.',
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  label: 'Aide & Support',
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Aide & Support'),
                          content: const Text(
                            'Contact : support@bookshare.app\nNous répondons sous 24 h.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              child: const Text('Fermer'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                // Section Admin (affiche toujours pour debug)
                // Dans le Column des enfants, après "Aide & Support" :
                if (user?.isAdmin == true) ...[
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    label: 'Administration',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 18),

                // Déconnexion
                _buildMenuItem(
                  icon: Icons.logout,
                  label: 'Déconnexion',
                  isLogout: true,
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmer la déconnexion'),
                          content: const Text(
                            'Voulez-vous vraiment vous déconnecter ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(false);
                              },
                              child: const Text('Annuler'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop(true);
                              },
                              child: const Text('Déconnexion'),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout != true) return;
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
          ),
        );
      },
    );
  }

  Future<void> _openEditNameDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final currentName = auth.currentUser?.name ?? '';
    final controller = TextEditingController(text: currentName);

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier mon nom'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              hintText: 'Entrez votre nom',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (submitted != true) {
      controller.dispose();
      return;
    }

    final success = await auth.updateProfileName(controller.text);
    controller.dispose();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
            ? 'Profil mis à jour avec succès.'
            : (auth.errorMessage ?? 'Mise à jour impossible.'),
        ),
        backgroundColor: success ? const Color(0xFF27AE60) : Colors.red,
      ),
    );
  }

  Future<XFile?> _pickProfileImage() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 700,
    );
  }

  Future<void> _openProfileImageActions(UserModel? user) async {
    if (!mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Modifier la photo'),
                onTap: () => Navigator.of(sheetContext).pop('edit'),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: user?.profileImageUrl?.isNotEmpty == true
                      ? Colors.red
                      : Colors.grey,
                ),
                title: Text(
                  'Supprimer la photo',
                  style: TextStyle(
                    color: user?.profileImageUrl?.isNotEmpty == true
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                onTap: user?.profileImageUrl?.isNotEmpty == true
                    ? () => Navigator.of(sheetContext).pop('delete')
                    : null,
              ),
            ],
          ),
        );
      },
    );

    if (action == 'edit') {
      if (!mounted) return;
      await _changeProfileImage();
      return;
    }

    if (action == 'delete') {
      await _removeProfileImage();
    }
  }

  Future<void> _changeProfileImage() async {
    if (!mounted) return;
    final pickedImage = await _pickProfileImage();
    if (pickedImage == null) return;

    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfileImage(pickedImage);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Photo de profil mise à jour.'
              : (auth.errorMessage ?? 'Mise à jour impossible.'),
        ),
        backgroundColor: success ? const Color(0xFF27AE60) : Colors.red,
      ),
    );
  }

  Future<void> _removeProfileImage() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.removeProfileImage();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Photo de profil supprimée.'
              : (auth.errorMessage ?? 'Suppression impossible.'),
        ),
        backgroundColor: success ? const Color(0xFF27AE60) : Colors.red,
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel? user) {
    final profileImageUrl = user?.profileImageUrl;
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      return Container(
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
      );
    }

    Widget imageWidget;
    if (profileImageUrl.startsWith('data:image/')) {
      final commaIndex = profileImageUrl.indexOf(',');
      final base64Part =
          commaIndex >= 0 ? profileImageUrl.substring(commaIndex + 1) : '';
      imageWidget = Image.memory(
        base64Decode(base64Part),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 36,
        ),
      );
    } else {
      imageWidget = Image.network(
        profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.broken_image,
          color: Colors.white,
          size: 36,
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF2C3E50),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageWidget,
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout
                    ? const Color(0xFFFADBD8)
                    : const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFF2C3E50),
                ),
              ),
            ),
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
