import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Écouter les changements d'état d'authentification
    _authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _currentUser = UserModel.fromFirebaseUser(
          firebaseUser.uid,
          firebaseUser.email!,
          firebaseUser.displayName ?? 'Utilisateur',
        );
        debugPrint('🔄 [AuthProvider] Utilisateur connecté: ${_currentUser!.email}');
      } else {
        _currentUser = null;
        debugPrint('🔄 [AuthProvider] Utilisateur déconnecté');
      }
      notifyListeners();
    });
  }

  /// Inscription
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('📝 [AuthProvider] Début inscription: $email');

      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      _currentUser = user;
      debugPrint('✅ [AuthProvider] Inscription réussie');

      // Retour à l'écran de connexion après inscription
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Erreur inscription: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Connexion
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔑 [AuthProvider] Début connexion: $email');

      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      _currentUser = user;
      debugPrint('✅ [AuthProvider] Connexion réussie');
      
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('❌ [AuthProvider] Erreur connexion: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.resetPassword(email);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Effacer les erreurs manuellement
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
