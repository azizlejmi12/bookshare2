import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final description = _buildDescription(book);
    final summary = _buildSummary(book);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail du livre'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 180,
                  height: 250,
                  child: (book.coverUrl != null && book.coverUrl!.isNotEmpty)
                      ? _buildCoverImage(book.coverUrl!)
                      : _buildPlaceholder(book.genre),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Auteur: ${book.author}',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Genre: ${book.genre}',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Petit resume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildDescription(BookModel book) {
    final value = book.description?.trim();
    if (value != null && value.isNotEmpty) return value;

    return '${book.title} est un livre de type ${book.genre.toLowerCase()} '
        'ecrit par ${book.author}. '
        'Cette fiche est simple et peut etre enrichie plus tard '
        'depuis l\'admin avec une vraie description.';
  }

  String _buildSummary(BookModel book) {
    final value = book.summary?.trim();
    if (value != null && value.isNotEmpty) return value;

    return 'Resume court: ce livre propose une lecture ${book.genre.toLowerCase()} '
        'avec un style accessible, ideale pour decouvrir l\'univers de ${book.author}.';
  }

  Widget _buildPlaceholder(String genre) {
    final colors = _getGradientForGenre(genre);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.menu_book, color: Colors.white, size: 58),
    );
  }

  List<Color> _getGradientForGenre(String genre) {
    switch (genre) {
      case 'Roman':
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case 'Science-fiction':
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      default:
        return [const Color(0xFFa8edea), const Color(0xFFfed6e3)];
    }
  }

  Widget _buildCoverImage(String source) {
    final bytes = _decodeDataUrl(source);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(book.genre),
      );
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(book.genre),
    );
  }

  Uint8List? _decodeDataUrl(String value) {
    if (!value.startsWith('data:image')) return null;
    final commaIndex = value.indexOf(',');
    if (commaIndex == -1 || commaIndex == value.length - 1) return null;

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } catch (_) {
      return null;
    }
  }
}
