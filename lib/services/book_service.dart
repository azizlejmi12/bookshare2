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
  }) {
    return _firestore.addBook(title: title, author: author, genre: genre);
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
  }) {
    return _firestore.updateBook(
      bookId: bookId,
      title: title,
      author: author,
      genre: genre,
    );
  }

  Future<void> toggleBookAvailability(String bookId, bool isAvailable) {
    return _firestore.toggleBookAvailability(bookId, isAvailable);
  }

  Future<void> deleteBook(String bookId) {
    return _firestore.deleteBook(bookId);
  }
}
