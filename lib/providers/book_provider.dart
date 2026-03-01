import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  
  List<BookModel> _books = [];
  List<BookModel> _recommendedBooks = [];
  bool _isLoading = false;
  String? _error;
  String _selectedGenre = 'Tous';

  // Getters (pour que les écrans puissent lire les données)
  List<BookModel> get books => _books;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedGenre => _selectedGenre;

  // Charger tous les livres depuis Firestore
  void loadBooks() {
    _setLoading(true);
    
    // Écoute Firestore en temps réel
    _firestore.getBooks().listen((books) {
      _books = books;
      // Les 5 premiers livres = recommandés
      _recommendedBooks = books.take(5).toList();
      _setLoading(false);
    }, onError: (e) {
      _setError(e.toString());
      _setLoading(false);
    });
  }

  // Filtrer par genre
  void filterByGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
    
    if (genre == 'Tous') {
      loadBooks();
    } else {
      _firestore.getBooksByGenre(genre).listen((books) {
        _books = books;
        _setLoading(false);
      });
    }
  }

  // Livres filtrés pour l'affichage
  List<BookModel> get filteredBooks {
    if (_selectedGenre == 'Tous') return _books;
    return _books.where((book) => book.genre == _selectedGenre).toList();
  }

  // Méthodes privées
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Prévient les écrans que ça a changé
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }
}