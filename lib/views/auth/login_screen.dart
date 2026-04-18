import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../views/home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _rememberMeEmailKey = 'remember_me_email';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_rememberMeEmailKey);

    if (!mounted || savedEmail == null || savedEmail.isEmpty) {
      return;
    }

    setState(() {
      emailController.text = savedEmail;
      rememberMe = true;
    });
  }

  Future<void> _updateRememberMeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe && email.isNotEmpty) {
      await prefs.setString(_rememberMeEmailKey, email);
    } else {
      await prefs.remove(_rememberMeEmailKey);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validation des champs
    if (!_validateFields()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Appel au provider
    final success = await authProvider.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (success && mounted) {
      await _updateRememberMeEmail(emailController.text.trim());

      // Connexion réussie - navigue vers HomeScreen
      debugPrint('📍 [LoginScreen] Navigation vers HomeScreen');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
      // Nettoie les champs
      emailController.clear();
      passwordController.clear();
    } else if (!success && mounted) {
      // Affiche l'erreur du provider
      _showError(authProvider.errorMessage ?? 'Erreur de connexion');
    }
  }

  Future<void> _handleForgotPassword() async {
    if (emailController.text.trim().isNotEmpty &&
        !emailController.text.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return;
    }

    final emailControllerDialog = TextEditingController(
      text: emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mot de passe oublié ?'),
          content: TextField(
            controller: emailControllerDialog,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse e-mail',
              hintText: 'votre@email.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(emailControllerDialog.text.trim());
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );

    emailControllerDialog.dispose();

    if (email == null || email.isEmpty) {
      return;
    }

    if (!email.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return;
    }

    if (!mounted) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(email);

    if (!mounted) {
      return;
    }

    if (success) {
      _showSuccess('Lien de réinitialisation envoyé à $email');
    } else {
      _showError(authProvider.errorMessage ?? 'Impossible d\'envoyer le lien');
    }
  }

  bool _validateFields() {
    if (emailController.text.trim().isEmpty) {
      _showError('Veuillez entrer votre email');
      return false;
    }
    if (!emailController.text.contains('@')) {
      _showError('Veuillez entrer un email valide');
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showError('Veuillez entrer votre mot de passe');
      return false;
    }
    if (passwordController.text.length < 6) {
      _showError('Le mot de passe doit faire au moins 6 caractères');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF27AE60),
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
                        _buildField(
                          'E-mail',
                          'votre@email.com',
                          Icons.email,
                          emailController,
                          isLoading,
                        ),
                        const SizedBox(height: 20),

                        // Mot de passe
                        _buildPasswordField(isLoading),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        rememberMe = value ?? false;
                                      });
                                    },
                              activeColor: const Color(0xFF2C3E50),
                            ),
                            const Expanded(
                              child: Text(
                                'Se souvenir de moi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : _handleForgotPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2C3E50),
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Mot de passe oublié ?'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bouton Se connecter
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
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
                                      Text(
                                        'Connexion...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Lien créer compte
                        Center(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      _showSuccess(
                                        'Compte créé. Connectez-vous.',
                                      );
                                    }
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
      },
    );
  }

  Widget _buildField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF7F8C8D)),
            filled: true,
            fillColor: isLoading
                ? Colors.grey.shade200
                : const Color(0xFFF5F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isLoading) {
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
              onPressed: isLoading
                  ? null
                  : () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
            ),
            filled: true,
            fillColor: isLoading
                ? Colors.grey.shade200
                : const Color(0xFFF5F5F0),
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
