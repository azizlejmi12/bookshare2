import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Utilitaire pour vérifier et configurer les admins
class AdminChecker {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Vérifier si un utilisateur est admin par son email
  static Future<void> checkUserAdmin(String email) async {
    try {
      debugPrint('🔍 Vérification admin pour: $email');
      
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (query.docs.isEmpty) {
        debugPrint('❌ Utilisateur $email non trouvé dans Firestore');
        return;
      }
      
      for (var doc in query.docs) {
        final data = doc.data();
        debugPrint('✅ Trouvé (ID: ${doc.id}):');
        debugPrint('   Email: ${data['email']}');
        debugPrint('   Name: ${data['name']}');
        debugPrint('   isAdmin: ${data['isAdmin']}');
      }
    } catch (e) {
      debugPrint('❌ Erreur: $e');
    }
  }

  /// Promouvoir un utilisateur en admin par son email
  static Future<void> promoteUserToAdmin(String email) async {
    try {
      debugPrint('🔧 Promotion admin pour: $email');
      
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (query.docs.isEmpty) {
        debugPrint('❌ Utilisateur $email non trouvé');
        throw Exception('Utilisateur non trouvé');
      }
      
      final userId = query.docs.first.id;
      
      // Mettre à jour isAdmin
      await _db.collection('users').doc(userId).update({
        'isAdmin': true,
      });
      
      debugPrint('✅ $email est maintenant admin!');
      
      // Vérifier
      final updated = await _db.collection('users').doc(userId).get();
      debugPrint('   Vérification: isAdmin = ${updated.data()?['isAdmin']}');
      
    } catch (e) {
      debugPrint('❌ Erreur promotion: $e');
      rethrow;
    }
  }

  /// Lister tous les utilisateurs et leur statut admin
  static Future<void> listAllUsers() async {
    try {
      debugPrint('📋 Liste des utilisateurs:');
      
      final query = await _db.collection('users').get();
      
      for (var doc in query.docs) {
        final data = doc.data();
        debugPrint('   - ${data['email']}: isAdmin = ${data['isAdmin'] ?? false}');
      }
      
    } catch (e) {
      debugPrint('❌ Erreur liste: $e');
    }
  }
}
