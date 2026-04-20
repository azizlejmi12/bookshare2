import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
          UserModel? user;
          try {
            user = await _firestoreService.getUser(firebaseUser.uid);
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
          } on FirebaseException catch (e) {
            if (e.code != 'permission-denied') rethrow;
            // Fallback pour éviter de bloquer l'utilisateur si les rules sont trop strictes.
            user = UserModel(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ?? 'Utilisateur',
              email: firebaseUser.email ?? '',
              createdAt: DateTime.now(),
              isAdmin: false,
            );
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
      _setError('Utilisateur non connecté.');
      return false;
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      _setError('Le nom ne peut pas être vide.');
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

  Future<bool> updateProfileImage(XFile image) async {
    final user = _currentUser;
    if (user == null) {
      _setError('Utilisateur non connecté.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final profileImageUrl = await _encodeProfileImageAsDataUrl(image);

      await _firestoreService.updateUser(
        uid: user.uid,
        name: user.name,
        email: user.email,
        profileImageUrl: profileImageUrl,
        shouldUpdateProfileImage: true,
      );

      _currentUser = user.copyWith(profileImageUrl: profileImageUrl);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeProfileImage() async {
    final user = _currentUser;
    if (user == null) {
      _setError('Utilisateur non connecté.');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateUser(
        uid: user.uid,
        name: user.name,
        email: user.email,
        profileImageUrl: null,
        shouldUpdateProfileImage: true,
      );

      _currentUser = user.copyWith(clearProfileImage: true);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<String> _encodeProfileImageAsDataUrl(XFile image) async {
    final bytes = await image.readAsBytes();

    // Même logique que les couvertures de livres pour respecter la limite Firestore.
    const maxRawSizeBytes = 450 * 1024;
    if (bytes.length > maxRawSizeBytes) {
      throw Exception(
        'Image trop lourde. Choisissez une image plus legere (max 450 Ko).',
      );
    }

    final extension = image.path.contains('.')
        ? image.path.split('.').last.toLowerCase()
        : 'jpg';

    return 'data:image/$extension;base64,${base64Encode(bytes)}';
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
    if (message.contains('permission-denied')) {
      _errorMessage =
          'Accès Firestore refusé. Vérifiez vos règles Firestore.';
    } else {
      _errorMessage = message;
    }
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
