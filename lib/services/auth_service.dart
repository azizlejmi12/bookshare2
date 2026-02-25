import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/user_model.dart';

/// Service qui encapsule toutes les opérations Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de l'utilisateur connecté
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Inscription avec email et mot de passe
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      debugPrint('🔥 [AuthService] Inscription: $email');

      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Impossible de créer l\'utilisateur');
      }

      debugPrint('✅ [AuthService] Utilisateur créé: ${userCredential.user!.uid}');

      // Créer le modèle utilisateur
      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!.uid,
        email,
        name,
      );

      // TODO: Sauvegarder dans Firestore si nécessaire
      // await _saveUserToFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] Erreur Firebase: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ [AuthService] Erreur générale: $e');
      rethrow;
    }
  }

  /// Connexion avec email et mot de passe
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔥 [AuthService] Connexion: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Impossible de se connecter');
      }

      debugPrint('✅ [AuthService] Connexion réussie: ${userCredential.user!.email}');

      // Créer le modèle utilisateur
      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!.uid,
        userCredential.user!.email!,
        userCredential.user!.displayName ?? 'Utilisateur',
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [AuthService] Erreur Firebase: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ [AuthService] Erreur générale: $e');
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      debugPrint('🔥 [AuthService] Déconnexion...');
      await _auth.signOut();
      debugPrint('✅ [AuthService] Déconnexion réussie');
    } catch (e) {
      debugPrint('❌ [AuthService] Erreur déconnexion: $e');
      rethrow;
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Gestion des erreurs Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Email invalide';
      case 'weak-password':
        return 'Mot de passe trop faible (min 6 caractères)';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'operation-not-allowed':
        return 'Les inscriptions ne sont pas activées';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion Internet';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return 'Erreur: ${e.message ?? e.code}';
    }
  }
}
