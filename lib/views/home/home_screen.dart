import 'package:bookshare/views/profil/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loans_provider.dart';
import '../../models/book_model.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/book_card.dart';
import '../../widgets/book_list_item.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/emprunt_card.dart';
import '../../widgets/tab_selector.dart';
import '../../widgets/profile_menu_item.dart';
import '../../widgets/message_item.dart';
import '../../models/loan_model.dart';
import '../../models/conversation_model.dart';
import '../catalogue/catalogue_screen.dart';
import '../auth/login_screen.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/users_provider.dart';
import '../chat/chat_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0; // Page actuelle (0 = Home)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const HomeContent(), // Page 0
        const CatalogueScreen(), // Page 1
        EmpruntsContent(
          onBackToHome: () {
            setState(() {
              currentPage = 0;
            });
          },
        ), // Page 2
        const MessagesContent(), // Page 3
        ProfileScreen(
          onOpenLoansTab: () {
            setState(() {
              currentPage = 2;
            });
          },
        ), // Page 4
      ][currentPage], // Affiche la page actuelle
      bottomNavigationBar: BottomNav(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index; // Change de page
          });
        },
      ),
    );
  }
}

// ===== CONTENU DE CHAQUE PAGE =====

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
        final filteredRecommended = _filterBooks(
          bookProvider.recommendedBooks,
          _searchQuery,
        );
        final filteredBooks = _filterBooks(bookProvider.books, _searchQuery);

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bleu
                Container(
                  color: const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📚 BookShare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.notifications, color: Colors.white),
                    ],
                  ),
                ),

                // Barre de recherche
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF7F8C8D),
                        ),
                        hintText: 'Rechercher un livre, auteur, genre...',
                        hintStyle: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontSize: 15,
                        ),
                        contentPadding: EdgeInsets.only(top: 10),
                      ),
                    ),
                  ),
                ),

                // Section RECOMMANDÉS (données Firestore)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    '📚 Recommandés',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),

                // Carousel avec vrais livres
                SizedBox(
                  height: 320,
                  child: bookProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredRecommended.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun livre recommande trouve.',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: filteredRecommended.map((book) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: BookCard(
                                title: book.title,
                                author: book.author,
                                isAvailable: book.isAvailable,
                                gradientColors: _getGradientForGenre(
                                  book.genre,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),

                // Section NOUVEAUTÉS
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    '✨ Nouveautés',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),

                // Liste avec vrais livres
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: bookProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredBooks.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Aucun resultat pour votre recherche.',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 15,
                            ),
                          ),
                        )
                      : Column(
                          children: filteredBooks.take(3).map((book) {
                            return BookListItem(
                              title: book.title,
                              author: book.author,
                              isAvailable: book.isAvailable,
                              gradientColors: _getGradientForGenre(book.genre),
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
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

  List<BookModel> _filterBooks(List<BookModel> books, String query) {
    if (query.isEmpty) return books;
    final normalized = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(normalized) ||
          book.author.toLowerCase().contains(normalized) ||
          book.genre.toLowerCase().contains(normalized);
    }).toList();
  }
}

class CatalogueContent extends StatelessWidget {
  const CatalogueContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER BLANC =====
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

          // ===== FILTRES =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(label: 'Tous', isSelected: true),
                  CategoryChip(label: 'Roman', isSelected: false),
                  CategoryChip(label: 'Policier', isSelected: false),
                  CategoryChip(label: 'SF', isSelected: false),
                  CategoryChip(label: 'BD', isSelected: false),
                ],
              ),
            ),
          ),

          // ===== LISTE DES LIVRES =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                BookListItem(
                  title: 'Le Petit Prince',
                  author: 'Saint-Exupéry',
                  isAvailable: true,
                  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                BookListItem(
                  title: '1984',
                  author: 'George Orwell',
                  isAvailable: false,
                  gradientColors: [Color(0xFFfa709a), Color(0xFFfee140)],
                ),
                BookListItem(
                  title: 'Dune',
                  author: 'Frank Herbert',
                  isAvailable: true,
                  gradientColors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
                ),
                BookListItem(
                  title: 'Harry Potter',
                  author: 'J.K. Rowling',
                  isAvailable: true,
                  gradientColors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CHANGEMENT : StatefulWidget au lieu de StatelessWidget
// Pour gérer les onglets cliquables
class EmpruntsContent extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const EmpruntsContent({super.key, this.onBackToHome});

  @override
  State<EmpruntsContent> createState() => _EmpruntsContentState();
}

class _EmpruntsContentState extends State<EmpruntsContent> {
  int selectedTab = 0; // 0 = En cours, 1 = Historique

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<LoansProvider>().watchUserLoans(auth.currentUser!.uid);
      }
      context.read<CatalogueProvider>().loadBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loansProvider = context.watch<LoansProvider>();
    final catalogueProvider = context.watch<CatalogueProvider>();

    if (auth.currentUser == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Connectez-vous pour voir vos emprunts.',
            style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 16),
          ),
        ),
      );
    }

    final activeLoans = loansProvider.activeLoans;
    final historyLoans = loansProvider.historyLoans;

    return SafeArea(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                  onPressed: () {
                    if (widget.onBackToHome != null) {
                      widget.onBackToHome!();
                      return;
                    }
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(width: 16),
                const Text(
                  'Mes Emprunts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),

          // ===== ONGLETS =====
          TabSelector(
            tabs: [
              'En cours (${activeLoans.length})',
              'Historique (${historyLoans.length})',
            ],
            selectedIndex: selectedTab,
            onTap: (index) {
              setState(() {
                selectedTab = index; // Change l'onglet
              });
            },
          ),

          // ===== CONTENU =====
          Expanded(
            child: loansProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : loansProvider.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        loansProvider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : selectedTab == 0
                ? _buildActiveLoans(
                    context,
                    activeLoans,
                    catalogueProvider,
                    loansProvider,
                  )
                : _buildHistoryLoans(context, historyLoans, catalogueProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLoans(
    BuildContext context,
    List<LoanModel> activeLoans,
    CatalogueProvider catalogueProvider,
    LoansProvider loansProvider,
  ) {
    if (activeLoans.isEmpty) {
      return const Center(
        child: Text(
          'Aucun emprunt en cours',
          style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: activeLoans.length,
      itemBuilder: (context, index) {
        final loan = activeLoans[index];
        final book = _findBook(catalogueProvider, loan.bookId);
        final dueDate = loan.dueDate;
        final isUrgent = dueDate.difference(DateTime.now()).inDays <= 3;

        return EmpruntCard(
          title: book?.title ?? _bookFallbackLabel(loan.bookId),
          author: book?.author ?? 'Auteur inconnu',
          returnDate:
              '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}',
          isUrgent: isUrgent,
          gradientColors: _getGradientForGenre(book?.genre ?? ''),
          secondaryActionLabel: loan.renewalCount > 0
              ? 'Deja prolonge'
              : 'Prolonger (+7j)',
          onPrimaryAction: () {
            _showLoanDetailsDialog(loan, book, loansProvider);
          },
          onSecondaryAction: loan.renewalCount > 0
              ? null
              : () async {
                  final success = await loansProvider.renewLoan(
                    loan.id,
                    extraDays: 7,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Emprunt prolonge de 7 jours.'
                            : (loansProvider.error ??
                                  'Prolongation impossible.'),
                      ),
                      backgroundColor: success
                          ? const Color(0xFF27AE60)
                          : Colors.red,
                    ),
                  );
                },
        );
      },
    );
  }

  Future<void> _showLoanDetailsDialog(
    LoanModel loan,
    BookModel? book,
    LoansProvider loansProvider,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(book?.title ?? _bookFallbackLabel(loan.bookId)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Auteur: ${book?.author ?? 'Auteur inconnu'}'),
              const SizedBox(height: 8),
              Text('Genre: ${book?.genre.isNotEmpty == true ? book!.genre : 'Non renseigne'}'),
              const SizedBox(height: 8),
              Text('Date d\'emprunt: ${_formatDate(loan.borrowDate)}'),
              const SizedBox(height: 8),
              Text('Date de retour: ${_formatDate(loan.dueDate)}'),
              const SizedBox(height: 8),
              Text('Prolongations: ${loan.renewalCount}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: dialogContext,
                  builder: (confirmContext) {
                    return AlertDialog(
                      title: const Text('Confirmer le retour'),
                      content: const Text(
                        'Voulez-vous vraiment retourner ce livre ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(confirmContext).pop(false);
                          },
                          child: const Text('Non'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(confirmContext).pop(true);
                          },
                          child: const Text('Oui'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed != true) return;
                if (!mounted) return;

                Navigator.of(context).pop();
                final success = await loansProvider.returnBook(
                  loan.id,
                  loan.bookId,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Livre retourne.'
                          : (loansProvider.error ?? 'Retour impossible.'),
                    ),
                    backgroundColor: success
                        ? const Color(0xFF27AE60)
                        : Colors.red,
                  ),
                );
              },
              child: const Text('Retourner le livre'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildHistoryLoans(
    BuildContext context,
    List<LoanModel> historyLoans,
    CatalogueProvider catalogueProvider,
  ) {
    if (historyLoans.isEmpty) {
      return const Center(
        child: Text(
          'Aucun historique',
          style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: historyLoans.length,
      itemBuilder: (context, index) {
        final loan = historyLoans[index];
        final book = _findBook(catalogueProvider, loan.bookId);
        final date = loan.returnDate ?? loan.dueDate;

        return EmpruntCard(
          title: book?.title ?? _bookFallbackLabel(loan.bookId),
          author: book?.author ?? 'Auteur inconnu',
          returnDate:
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
          isUrgent: false,
          gradientColors: _getGradientForGenre(book?.genre ?? ''),
          primaryActionLabel: 'Detail',
          secondaryActionLabel: 'Termine',
          onPrimaryAction: () {},
          onSecondaryAction: null,
        );
      },
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

  BookModel? _findBook(CatalogueProvider catalogueProvider, String bookId) {
    for (final book in catalogueProvider.books) {
      if (book.id == bookId) return book;
    }
    return null;
  }

  String _bookFallbackLabel(String bookId) {
    if (bookId.isEmpty) return 'Livre inconnu';
    final size = bookId.length > 6 ? 6 : bookId.length;
    return 'Livre #${bookId.substring(0, size)}';
  }
}

class MessagesContent extends StatefulWidget {
  const MessagesContent({super.key});

  @override
  State<MessagesContent> createState() => _MessagesContentState();
}

class _MessagesContentState extends State<MessagesContent> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<MessagesProvider>().watchConversations(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final messagesProvider = context.watch<MessagesProvider>();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            'Connectez-vous pour voir vos messages.',
            style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 16),
          ),
        ),
      );
    }

    final filteredConversations = _filterConversations(
      messagesProvider.conversations,
      currentUser.uid,
      _searchQuery,
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _openCreateConversationDialog(currentUser.uid),
                  icon: const Icon(Icons.add_comment_outlined),
                  tooltip: 'Nouvelle conversation',
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Color(0xFF7F8C8D)),
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Color(0xFF7F8C8D), fontSize: 15),
                ),
              ),
            ),
          ),

          Expanded(
            child: messagesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messagesProvider.error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        messagesProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : filteredConversations.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune conversation pour le moment.',
                      style: TextStyle(color: Color(0xFF7F8C8D), fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      final displayName = conversation.displayNameFor(
                        currentUser.uid,
                      );
                      final unreadCount = conversation.unreadFor(
                        currentUser.uid,
                      );
                      final preview = conversation.lastMessage.isNotEmpty
                          ? conversation.lastMessage
                          : 'Commencez la conversation';

                      return MessageItem(
                        name: displayName,
                        message: preview,
                        time: _formatConversationTime(conversation.updatedAt),
                        unreadCount: unreadCount,
                        isAdmin: displayName.toLowerCase().contains('bibli'),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Supprimer la conversation'),
                                content: Text(
                                  'Voulez-vous supprimer la conversation avec $displayName ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false);
                                    },
                                    child: const Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE74C3C),
                                    ),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm != true) return;
                          if (!context.mounted) return;
                          final success = await context
                              .read<MessagesProvider>()
                              .deleteConversation(
                                conversationId: conversation.id,
                                userId: currentUser.uid,
                              );
                          if (!context.mounted) return;

                          if (!success) {
                            final error =
                                context.read<MessagesProvider>().error ??
                                'Suppression impossible.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conversation supprimee.'),
                              backgroundColor: Color(0xFF27AE60),
                            ),
                          );
                        },
                        onTap: () async {
                          await context
                              .read<MessagesProvider>()
                              .markConversationAsRead(
                                conversationId: conversation.id,
                                userId: currentUser.uid,
                              );
                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailScreen(
                                conversation: conversation,
                                currentUserId: currentUser.uid,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ConversationModel> _filterConversations(
    List<ConversationModel> conversations,
    String currentUserId,
    String query,
  ) {
    if (query.isEmpty) return conversations;
    final normalized = query.toLowerCase();
    return conversations.where((conversation) {
      final name = conversation.displayNameFor(currentUserId).toLowerCase();
      final preview = conversation.lastMessage.toLowerCase();
      return name.contains(normalized) || preview.contains(normalized);
    }).toList();
  }

  String _formatConversationTime(DateTime? date) {
    if (date == null) return '--:--';
    final now = DateTime.now();

    if (_isSameDay(now, date)) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(yesterday, date)) return 'Hier';

    final d = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    return '$d/$mo';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _openCreateConversationDialog(String currentUserId) async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final usersProvider = context.read<UsersProvider>();
    usersProvider.loadUsers();
    String search = '';

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nouvelle conversation'),
              content: SizedBox(
                width: 380,
                child: Consumer<UsersProvider>(
                  builder: (context, liveUsersProvider, _) {
                    final filteredUsers = liveUsersProvider.users.where((user) {
                      if (user.uid == currentUserId) return false;
                      if (search.isEmpty) return true;

                      final normalized = search.toLowerCase();
                      return user.name.toLowerCase().contains(normalized) ||
                          user.email.toLowerCase().contains(normalized) ||
                          user.uid.toLowerCase().contains(normalized);
                    }).toList();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) {
                            setDialogState(() {
                              search = value.trim();
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Rechercher un utilisateur...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (liveUsersProvider.isLoading &&
                            liveUsersProvider.users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          )
                        else if (liveUsersProvider.error != null)
                          Text(
                            liveUsersProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          )
                        else if (filteredUsers.isEmpty)
                          const Text(
                            'Aucun utilisateur trouve.',
                            style: TextStyle(color: Color(0xFF7F8C8D)),
                          )
                        else
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text(user.email),
                                  trailing: user.isAdmin
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE67E22),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'ADMIN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.of(dialogContext).pop({
                                      'otherUid': user.uid,
                                      'otherName': user.name,
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;
    if (!mounted) return;
    final messagesProvider = context.read<MessagesProvider>();

    final conversationId = await messagesProvider.createConversation(
      currentUserId: currentUser.uid,
      currentUserName: currentUser.name,
      otherUserId: result['otherUid']!,
      otherUserName: result['otherName']!,
    );

    if (!mounted) return;

    if (conversationId == null || conversationId.isEmpty) {
      final error = messagesProvider.error ?? 'Creation impossible.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    ConversationModel? conversation;
    for (final item in messagesProvider.conversations) {
      if (item.id == conversationId) {
        conversation = item;
        break;
      }
    }

    conversation ??= ConversationModel(
      id: conversationId,
      participants: [currentUser.uid, result['otherUid']!],
      participantNames: {
        currentUser.uid: currentUser.name,
        result['otherUid']!: result['otherName']!,
      },
      lastMessage: '',
      lastMessageAt: null,
      updatedAt: null,
      unreadCount: {
        currentUser.uid: 0,
        result['otherUid']!: 0,
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          conversation: conversation!,
          currentUserId: currentUser.uid,
        ),
      ),
    );
  }
}

class ProfilContent extends StatelessWidget {
  const ProfilContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ===== HEADER =====
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: Text(
                      'Mon Profil',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ),

                // ===== SECTION PROFIL (avatar + infos) =====
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C3E50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nom
                      Text(
                        user?.name ?? 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Email
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Badge "Membre depuis"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Membre depuis ${user?.createdAt.year ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ===== MENU =====
                ProfileMenuItem(
                  icon: Icons.menu_book,
                  label: 'Mes emprunts',
                  onTap: () {
                    // Naviguer vers Emprunts
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {
                    // Naviguer vers Notifications
                  },
                ),

                const SizedBox(height: 16),

                ProfileMenuItem(
                  icon: Icons.help_outline,
                  label: 'Aide & Support',
                  onTap: () {},
                ),
                ProfileMenuItem(
                  icon: Icons.logout,
                  label: 'Déconnexion',
                  isLogout: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Déconnexion'),
                        content: const Text(
                          'Voulez-vous vraiment vous déconnecter ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              await auth.signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text(
                              'Déconnexion',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
