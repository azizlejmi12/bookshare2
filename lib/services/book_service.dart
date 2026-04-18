import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../models/book_model.dart';
import 'firestore_service.dart';

class BookService {
  final FirestoreService _firestore = FirestoreService();

  Stream<List<BookModel>> getBooks() => _firestore.getBooks();

  Stream<List<BookModel>> getBooksByGenre(String genre) {
    return _firestore.getBooksByGenre(genre);
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
    XFile? coverImage,
  }) async {
    final bookId = await _firestore.addBook(
      title: title,
      author: author,
      genre: genre,
    );

    if (coverImage == null) return;

    final coverUrl = await _encodeCoverAsDataUrl(coverImage);
    await _firestore.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      genre: genre,
      coverUrl: coverUrl,
    );
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
    XFile? coverImage,
  }) async {
    String? coverUrl;
    if (coverImage != null) {
      coverUrl = await _encodeCoverAsDataUrl(coverImage);
    }

    return _firestore.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      genre: genre,
      coverUrl: coverUrl,
    );
  }

  Future<String> _encodeCoverAsDataUrl(XFile image) async {
    final bytes = await image.readAsBytes();

    // Firestore a une limite de 1 MiB par document.
    // On borne la taille brute pour garder une marge après encodage Base64.
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

  Future<void> toggleBookAvailability(String bookId, bool isAvailable) {
    return _firestore.toggleBookAvailability(bookId, isAvailable);
  }

  Future<void> deleteBook(String bookId) {
    return _firestore.deleteBook(bookId);
  }
}
