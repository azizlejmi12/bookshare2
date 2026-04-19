import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UsersProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<List<UserModel>>? _usersSubscription;

  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger tous les utilisateurs
  void loadUsers() {
    _setLoading(true);
    _usersSubscription?.cancel();

    _usersSubscription = _firestore.getAllUsers().listen(
      (users) {
        _users = users;
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  // Promouvoir en admin
  Future<void> promoteToAdmin(String userId) async {
    await _firestore.promoteToAdmin(userId);
    // Le stream mettra à jour automatiquement
  }

  // Rétrograder (enlever admin)
  Future<void> demoteFromAdmin(String userId) async {
    await _firestore.demoteFromAdmin(userId);
    // Le stream mettra à jour automatiquement
  }

  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
  }) {
    return _firestore.updateUser(uid: uid, name: name, email: email);
  }

  Future<void> deleteUser(String uid) {
    return _firestore.deleteUser(uid);
  }

  Future<void> createMember({
    required String name,
    required String email,
    required String password,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp-${DateTime.now().millisecondsSinceEpoch}',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      final secondaryAuth = fb_auth.FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        isAdmin: false,
      );
      await _firestore.saveUser(user);
    } finally {
      await secondaryApp.delete();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    if (message.contains('permission-denied')) {
      _error =
          'Accès refusé à la liste des utilisateurs. Publiez les règles Firestore mises à jour.';
    } else {
      _error = message;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}
