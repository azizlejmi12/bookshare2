import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/loans_provider.dart';
import '../../widgets/book_list_item.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/review_widget.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final Set<String> _busyBookIds = <String>{};
  final Set<String> _alertRegisteredBookIds = <String>{};
  bool _isSearchMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charge les livres au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogueProvider>().loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogueProvider>(
      builder: (context, bookProvider, child) {
        final books = bookProvider.filteredBooks;
        final displayedBooks = _searchQuery.trim().isEmpty
            ? books
            : books.where((book) {
                final query = _searchQuery.trim().toLowerCase();
                return book.title.toLowerCase().contains(query) ||
                    book.author.toLowerCase().contains(query) ||
                    book.genre.toLowerCase().contains(query);
              }).toList();

        return SafeArea(
          child: Column(
            children: [
              // Header blanc
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'refresh':
                            context.read<CatalogueProvider>().loadBooks();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Catalogue actualise.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            break;
                          case 'all':
                            bookProvider.filterByGenre('Tous');
                            break;
                          case 'roman':
                            bookProvider.filterByGenre('Roman');
                            break;
                          case 'sf':
                            bookProvider.filterByGenre('Science-fiction');
                            break;
                        }
                      },
                      icon: const Icon(Icons.menu, color: Color(0xFF2C3E50)),
                      itemBuilder: (context) => const [
                        PopupMenuItem<String>(
                          value: 'refresh',
                          child: Text('Actualiser'),
                        ),
                        PopupMenuItem<String>(
                          value: 'all',
                          child: Text('Tous les genres'),
                        ),
                        PopupMenuItem<String>(
                          value: 'roman',
                          child: Text('Roman'),
                        ),
                        PopupMenuItem<String>(
                          value: 'sf',
                          child: Text('Science-fiction'),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _isSearchMode
                            ? TextField(
                                key: const ValueKey('catalogue-search'),
                                autofocus: true,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Rechercher un livre...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              )
                            : const Text(
                                'Catalogue',
                                key: ValueKey('catalogue-title'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearchMode = !_isSearchMode;
                          if (!_isSearchMode) {
                            _searchQuery = '';
                          }
                        });
                      },
                      icon: Icon(
                        _isSearchMode ? Icons.close : Icons.search,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
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
                        isSelected:
                            bookProvider.selectedGenre == 'Science-fiction',
                        onTap: () =>
                            bookProvider.filterByGenre('Science-fiction'),
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
                    ? Center(
                        child: Text(
                          'Erreur lors du chargement du catalogue : ${bookProvider.error}',
                        ),
                      )
                    : displayedBooks.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun livre ne correspond a la recherche.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: displayedBooks.length,
                        itemBuilder: (context, index) {
                          final book = displayedBooks[index];
                          final isBusy = _busyBookIds.contains(book.id);
                          final hasRegisteredAlert =
                              _alertRegisteredBookIds.contains(book.id) &&
                              !book.isAvailable;

                          return BookListItem(
                            title: book.title,
                            author: book.author,
                            isAvailable: book.isAvailable,
                            coverUrl: book.coverUrl,
                            gradientColors: _getGradientForGenre(book.genre),
                            isActionLoading: isBusy,
                            actionLabel: hasRegisteredAlert
                                ? 'Alerte créée'
                                : null,
                            onBorrow: (isBusy || hasRegisteredAlert)
                                ? null
                                : () async {
                                    setState(() {
                                      _busyBookIds.add(book.id);
                                    });

                                    final auth = context.read<AuthProvider>();
                                    final loans = context.read<LoansProvider>();

                                    if (!auth.isAuthenticated ||
                                        auth.currentUser == null) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Connectez-vous pour emprunter un livre.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      }
                                      setState(() {
                                        _busyBookIds.remove(book.id);
                                      });
                                      return;
                                    }

                                    try {
                                      final success = await loans.borrowBook(
                                        userId: auth.currentUser!.uid,
                                        bookId: book.id,
                                        durationDays: 7,
                                      );

                                      if (!context.mounted) return;
                                      final subscribedToAlert =
                                          !success &&
                                          (loans.activeError ?? '').contains(
                                            'Vous serez notifié',
                                          );

                                      if (subscribedToAlert) {
                                        setState(() {
                                          _alertRegisteredBookIds.add(book.id);
                                        });
                                      }

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Livre emprunté, retour prévu sous 7 jours.'
                                                : subscribedToAlert
                                                ? 'Alerte enregistrée : vous serez notifié quand ce livre redeviendra disponible.'
                                                : (loans.error ??
                                                      'Impossible d\'emprunter ce livre.'),
                                          ),
                                          backgroundColor: success
                                              ? const Color(0xFF27AE60)
                                              : subscribedToAlert
                                              ? const Color(0xFFE67E22)
                                              : Colors.red,
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _busyBookIds.remove(book.id);
                                        });
                                      }
                                    }
                                  },
                            onReviews: () => _openReviewsSheet(book),
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

  void _openReviewsSheet(BookModel book) {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated || auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour laisser un avis.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUser = auth.currentUser!;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7F4EE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          height: MediaQuery.of(sheetContext).size.height * 0.92,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${book.author} • ${book.genre.isNotEmpty ? book.genre : 'Genre inconnu'}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    child: ReviewsList(
                      bookId: book.id,
                      userId: currentUser.uid,
                      userName: currentUser.name,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
