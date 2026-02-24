import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool obscurePassword = true;
  bool isLoading = false;

  // 🔥 FONCTION DE CONNEXION FIREBASE
  Future<void> login() async {
    // Validation des champs
    if (!validateFields()) return;

    setState(() => isLoading = true);

    try {
      // 🔥 APPEL FIREBASE AUTH
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Succès ! Va vers Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 🔥 GESTION DES ERREURS FIREBASE
      String message = 'Erreur de connexion';
      
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé avec cet email';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      } else if (e.code == 'user-disabled') {
        message = 'Ce compte a été désactivé';
      }
      
      showError(message);
    } catch (e) {
      showError('Erreur : ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool validateFields() {
    if (emailController.text.trim().isEmpty) {
      showError('Veuillez entrer votre email');
      return false;
    }
    if (!emailController.text.contains('@')) {
      showError('Veuillez entrer un email valide');
      return false;
    }
    if (passwordController.text.isEmpty) {
      showError('Veuillez entrer votre mot de passe');
      return false;
    }
    if (passwordController.text.length < 6) {
      showError('Le mot de passe doit faire au moins 6 caractères');
      return false;
    }
    return true;
  }

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
                    _buildField('E-mail', 'votre@email.com', Icons.email, emailController),
                    const SizedBox(height: 20),

                    // Mot de passe
                    _buildPasswordField(),
                    const SizedBox(height: 30),

                    // Bouton Se connecter
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C3E50),
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Connexion...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien créer compte
                    Center(
                      child: TextButton(
                        onPressed: isLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
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

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
            filled: true,
            fillColor: isLoading ? Colors.grey.shade200 : const Color(0xFFF5F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mot de passe', style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF7F8C8D)),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF7F8C8D),
              ),
              onPressed: isLoading ? null : () {
                setState(() => obscurePassword = !obscurePassword);
              },
            ),
            filled: true,
            fillColor: isLoading ? Colors.grey.shade200 : const Color(0xFFF5F5F0),
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