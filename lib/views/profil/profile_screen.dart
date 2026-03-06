import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;
        print('╔════════════════════════════════════╗');
        print('║ DEBUG PROFILE SCREEN               ║');
        print('╠════════════════════════════════════╣');
        print('║ user?.name: ${user?.name}          ║');
        print('║ user?.email: ${user?.email}        ║');
        print('║ user?.isAdmin: ${user?.isAdmin}    ║');
        print('║ runtimeType: ${user?.isAdmin.runtimeType} ║');
        print('║ isAdmin == true: ${user?.isAdmin == true} ║');
        print('╚════════════════════════════════════╝');
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

              // Menu
              _buildMenuItem(
                icon: Icons.menu_book,
                label: 'Mes emprunts',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                icon: Icons.help_outline,
                label: 'Aide & Support',
                onTap: () {},
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
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLogout ? const Color(0xFFFADBD8) : const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout ? const Color(0xFFE74C3C) : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isLogout ? const Color(0xFFE74C3C) : const Color(0xFF2C3E50),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? const Color(0xFFE74C3C) : const Color(0xFF7F8C8D),
            ),
          ],
        ),
      ),
    );
  }
}