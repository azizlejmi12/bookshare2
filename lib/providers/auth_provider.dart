import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Provider pour gérer l'état d'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<User?>? _authStateSubscription;

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
    _authStateSubscription = _authService.authStateChanges.listen(
      (User? firebaseUser) async {
        if (firebaseUser != null) {
          UserModel? user = await _firestoreService.getUser(firebaseUser.uid);
          if (user == null) {
            user = UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'Utilisateur',
              email: firebaseUser.email ?? '',
              createdAt: DateTime.now(),
              isAdmin: false,
            );
            await _firestoreService.saveUser(user);
          }
          _currentUser = user;
        } else {
          _currentUser = null;
        }
        notifyListeners();
      },
      onError: (Object e) {
        _setError(e.toString());
        notifyListeners();
      },
    );
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
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔑 [AuthProvider] Début connexion: $email');

      final user = await _authService.signIn(email: email, password: password);

      _currentUser = user;
      debugPrint('✅ [AuthProvider] Connexion réussie pour: ${user.email}');

      _setLoading(false);
      notifyListeners();
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

  Future<bool> updateProfileName(String newName) async {
    final user = _currentUser;
    if (user == null) {
      _setError('Utilisateur non connecte');
      return false;
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      _setError('Le nom ne peut pas etre vide');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateUser(
        uid: user.uid,
        name: trimmed,
        email: user.email,
      );

      _currentUser = user.copyWith(name: trimmed);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
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

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
