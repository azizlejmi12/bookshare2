import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/book_service.dart';

class CatalogueProvider extends ChangeNotifier {
  final BookService _bookService = BookService();
  StreamSubscription<List<BookModel>>? _booksSubscription;

  List<BookModel> _books = [];
  List<BookModel> _recommendedBooks = [];
  bool _isLoading = false;
  String? _error;
  String _selectedGenre = 'Tous';

  List<BookModel> get books => _books;
  List<BookModel> get recommendedBooks => _recommendedBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedGenre => _selectedGenre;

  void loadBooks() {
    _setLoading(true);
    _booksSubscription?.cancel();

    _booksSubscription = _bookService.getBooks().listen(
      (books) {
        _books = books;
        _recommendedBooks = books.take(5).toList();
        _setLoading(false);
      },
      onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      },
    );
  }

  void filterByGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();

    if (genre == 'Tous') {
      loadBooks();
      return;
    }

    _setLoading(true);
    _booksSubscription?.cancel();
    _booksSubscription = _bookService
        .getBooksByGenre(genre)
        .listen(
          (books) {
            _books = books;
            _setLoading(false);
          },
          onError: (e) {
            _setError(e.toString());
            _setLoading(false);
          },
        );
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
  }) {
    return _bookService.addBook(title: title, author: author, genre: genre);
  }

  Future<void> toggleBookAvailability(String bookId, bool isAvailable) {
    return _bookService.toggleBookAvailability(bookId, isAvailable);
  }

  Future<void> deleteBook(String bookId) {
    return _bookService.deleteBook(bookId);
  }

  List<BookModel> get filteredBooks {
    if (_selectedGenre == 'Tous') return _books;
    return _books.where((book) => book.genre == _selectedGenre).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _booksSubscription?.cancel();
    super.dispose();
  }
}
