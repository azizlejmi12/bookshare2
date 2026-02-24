import 'package:flutter/material.dart';
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

  // 🔥 Variables pour masquer les mots de passe
  bool obscurePassword = true;
  bool obscureConfirm = true;

  // 🔥 Fonction de validation complète
  bool validateFields() {
    // Nom
    if (nameController.text.trim().isEmpty) {
      showError('Veuillez entrer votre nom');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      showError('Le nom doit faire au moins 2 caractères');
      return false;
    }

    // Email
    if (emailController.text.trim().isEmpty) {
      showError('Veuillez entrer votre email');
      return false;
    }

    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      showError('Veuillez entrer un email valide');
      return false;
    }

    // Mot de passe
    if (passwordController.text.isEmpty) {
      showError('Veuillez entrer un mot de passe');
      return false;
    }

    if (passwordController.text.length < 6) {
      showError('Le mot de passe doit faire au moins 6 caractères');
      return false;
    }

    // Confirmation
    if (confirmController.text.isEmpty) {
      showError('Veuillez confirmer votre mot de passe');
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Créer un compte',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
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
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 40),

            // Nom
            _buildField('Nom complet', 'votre Nom', Icons.person, nameController),
            const SizedBox(height: 16),

            // Email
            _buildField('E-mail', 'votre@email.com', Icons.email, emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            // Mot de passe avec œil
            _buildPasswordField('Mot de passe', '••••••••', Icons.lock, passwordController, true),
            const SizedBox(height: 16),

            // Confirmation avec œil
            _buildPasswordField('Confirmer le mot de passe', '••••••••', Icons.lock_outline, confirmController, false),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 🔥 Vérifie tout avant d'inscrire
                  if (validateFields()) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
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
                  'S\'inscrire',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Déjà un compte ? Se connecter',
                style: TextStyle(color: Color(0xFF2C3E50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
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

  // 🔥 Champ mot de passe avec œil
  Widget _buildPasswordField(String label, String hint, IconData icon, TextEditingController controller, bool isPasswordField) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPasswordField ? obscurePassword : obscureConfirm,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordField 
                  ? (obscurePassword ? Icons.visibility_off : Icons.visibility)
                  : (obscureConfirm ? Icons.visibility_off : Icons.visibility),
                color: const Color(0xFF7F8C8D),
              ),
              onPressed: () {
                setState(() {
                  if (isPasswordField) {
                    obscurePassword = !obscurePassword;
                  } else {
                    obscureConfirm = !obscureConfirm;
                  }
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