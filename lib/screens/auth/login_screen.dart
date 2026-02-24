import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 🔥 Variable pour afficher/masquer le mot de passe
  bool obscurePassword = true;

  // 🔥 Fonction de validation
  bool validateFields() {
    // Vérifie email vide
    if (emailController.text.trim().isEmpty) {
      showError('Veuillez entrer votre email');
      return false;
    }

    // Vérifie format email simple (contient @ et .)
    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      showError('Veuillez entrer un email valide');
      return false;
    }

    // Vérifie mot de passe vide
    if (passwordController.text.isEmpty) {
      showError('Veuillez entrer votre mot de passe');
      return false;
    }

    // Vérifie longueur mot de passe
    if (passwordController.text.length < 6) {
      showError('Le mot de passe doit faire au moins 6 caractères');
      return false;
    }

    return true;
  }

  // 🔥 Affiche une erreur en bas de l'écran
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Column(
        children: [
          // Partie bleue (logo)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text('📚', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text(
                  'BookShare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre bibliothèque de quartier',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          // Partie blanche (formulaire)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email
                    _buildEmailField(),
                    const SizedBox(height: 20),

                    // Mot de passe avec œil 👁️
                    _buildPasswordField(),
                    const SizedBox(height: 30),

                    // Bouton Se connecter
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // 🔥 Vérifie avant de naviguer
                          if (validateFields()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien créer compte
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Pas de compte ? Créer un compte',
                          style: TextStyle(color: Color(0xFF2C3E50)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 Champ email avec validation visuelle
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'E-mail',
          style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'votre@email.com',
            prefixIcon: const Icon(Icons.email, color: Color(0xFF7F8C8D)),
            filled: true,
            fillColor: const Color(0xFFF5F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 Champ mot de passe avec œil pour afficher/masquer
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mot de passe',
          style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword, // Cache ou montre le texte
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF7F8C8D)),
            // 🔥 Icône œil à droite
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF7F8C8D),
              ),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword; // Inverse l'état
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}