import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validation des champs
    if (!_validateFields()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Appel au provider
    final success = await authProvider.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      name: nameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context, true);
      return;
    }
    if (!success && mounted) {
      // Affiche l'erreur du provider
      _showError(authProvider.errorMessage ?? 'Erreur d\'inscription');
    }
  }

  bool _validateFields() {
    if (nameController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre nom');
      return false;
    }
    if (nameController.text.trim().length < 2) {
      _showError('Le nom doit faire au moins 2 caractères');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre email');
      return false;
    }
    if (!emailController.text.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError('Le mot de passe doit faire au moins 6 caractères');
      return false;
    }
    if (passwordController.text != confirmController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return false;
    }
    return true;
  }

  void _showError(String message) {
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoading = authProvider.isLoading;

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

                _buildField('Nom complet', 'votre Nom', Icons.person, nameController, isLoading),
                const SizedBox(height: 16),
                _buildField('E-mail', 'votre@email.com', Icons.email, emailController, isLoading),
                const SizedBox(height: 16),
                _buildPasswordField('Mot de passe', passwordController, true, isLoading),
                const SizedBox(height: 16),
                _buildPasswordField('Confirmer le mot de passe', confirmController, false, isLoading),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
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
      },
    );
  }

  Widget _buildField(String label, String hint, IconData icon, TextEditingController controller, bool isLoading) {
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

  Widget _buildPasswordField(String label, TextEditingController controller, bool isPassword, bool isLoading) {
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
              onPressed: isLoading
                  ? null
                  : () {
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
