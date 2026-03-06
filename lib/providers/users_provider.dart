import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UsersProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger tous les utilisateurs
  void loadUsers() {
    _setLoading(true);
    
    _firestore.getAllUsers().listen((users) {
      _users = users;
      _setLoading(false);
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}