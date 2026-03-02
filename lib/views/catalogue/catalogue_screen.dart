import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_list_item.dart';
import '../../widgets/category_chip.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les livres au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookProvider>(
      builder: (context, bookProvider, child) {
        return SafeArea(
          child: Column(
            children: [
              // Header blanc
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, color: Color(0xFF2C3E50)),
                    const Text(
                      'Catalogue',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Icon(Icons.search, color: Color(0xFF2C3E50)),
                  ],
                ),
              ),

              // Filtres
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CategoryChip(
                        label: 'Tous',
                        isSelected: bookProvider.selectedGenre == 'Tous',
                        onTap: () => bookProvider.filterByGenre('Tous'),
                      ),
                      CategoryChip(
                        label: 'Roman',
                        isSelected: bookProvider.selectedGenre == 'Roman',
                        onTap: () => bookProvider.filterByGenre('Roman'),
                      ),
                      CategoryChip(
                        label: 'Science-fiction',
                        isSelected: bookProvider.selectedGenre == 'Science-fiction',
                        onTap: () => bookProvider.filterByGenre('Science-fiction'),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des livres
              Expanded(
                child: bookProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bookProvider.error != null
                    ? Center(child: Text('Erreur: ${bookProvider.error}'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: bookProvider.filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = bookProvider.filteredBooks[index];
                          return BookListItem(
                            title: book.title,
                            author: book.author,
                            isAvailable: book.isAvailable,
                            gradientColors: _getGradientForGenre(book.genre),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Couleurs selon le genre
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
}