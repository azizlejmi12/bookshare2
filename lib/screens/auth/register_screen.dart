import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  // 🔥 FONCTION D'INSCRIPTION FIREBASE
  Future<void> register() async {
    if (!validateFields()) return;

    setState(() => isLoading = true);

    try {
      // 🔥 CRÉE L'UTILISATEUR DANS FIREBASE
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Succès ! Va vers Home
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // 🔥 GESTION DES ERREURS
      String message = 'Erreur d\'inscription';
      
      if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide';
      } else if (e.code == 'weak-password') {
        message = 'Mot de passe trop faible (min 6 caractères)';
      }
      
      showError(message);
    } catch (e) {
      showError('Erreur : ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  bool validateFields() {
    if (nameController.text.trim().isEmpty) {
      showError('Veuillez entrer votre nom');
      return false;
    }
    if (nameController.text.trim().length < 2) {
      showError('Le nom doit faire au moins 2 caractères');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      showError('Veuillez entrer votre email');
      return false;
    }
    if (!emailController.text.contains('@')) {
      showError('Veuillez entrer un email valide');
      return false;
    }
    if (passwordController.text.length < 6) {
      showError('Le mot de passe doit faire au moins 6 caractères');
      return false;
    }
    if (passwordController.text != confirmController.text) {
      showError('Les mots de passe ne correspondent pas');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text('📚', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 8),
            const Text(
              'BookShare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 40),

            _buildField('Nom complet', 'votre Nom', Icons.person, nameController),
            const SizedBox(height: 16),
            _buildField('E-mail', 'votre@email.com', Icons.email, emailController),
            const SizedBox(height: 16),
            _buildPasswordField('Mot de passe', passwordController, true),
            const SizedBox(height: 16),
            _buildPasswordField('Confirmer le mot de passe', confirmController, false),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text('Inscription...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Déjà un compte ? Se connecter', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
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
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
            filled: true,
            fillColor: isLoading ? Colors.grey.shade200 : const Color(0xFFF5F5F0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isPassword) {
    bool isObscure = isPassword ? obscurePassword : obscureConfirm;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF7F8C8D)),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF7F8C8D)),
              onPressed: isLoading ? null : () {
                setState(() {
                  if (isPassword) {
                    obscurePassword = !obscurePassword;
                  } else {
                    obscureConfirm = !obscureConfirm;
                  }
                });
              },
            ),
            filled: true,
            fillColor: isLoading ? Colors.grey.shade200 : const Color(0xFFF5F5F0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}