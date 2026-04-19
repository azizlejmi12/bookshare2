import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// Widget pour les livres en format liste (Nouveautés)
class BookListItem extends StatelessWidget {
  final String title;
  final String author;
  final bool isAvailable;
  final String? coverUrl;
  final List<Color> gradientColors;
  final VoidCallback? onBorrow;
  final VoidCallback? onReviews;
  final bool isActionLoading;
  final String? actionLabel;

  const BookListItem({
    super.key,
    required this.title,
    required this.author,
    required this.isAvailable,
    this.coverUrl,
    required this.gradientColors,
    this.onBorrow,
    this.onReviews,
    this.isActionLoading = false,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image petite
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 110,
              child: (coverUrl != null && coverUrl!.isNotEmpty)
                  ? _buildCoverImage(coverUrl!)
                  : _buildGradientPlaceholder(),
            ),
          ),

          const SizedBox(width: 16),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFE67E22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Disponible' : 'Prêté',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (onBorrow != null)
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: isActionLoading ? null : onBorrow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable
                            ? const Color(0xFF2C3E50)
                            : const Color(0xFFE67E22),
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: isActionLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              actionLabel ??
                                  (isAvailable ? 'Emprunter' : 'Me notifier'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                if (onReviews != null) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: onReviews,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2C3E50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: const Icon(
                        Icons.star_outline,
                        size: 16,
                        color: Color(0xFF2C3E50),
                      ),
                      label: const Text(
                        'Avis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildCoverImage(String source) {
    final bytes = _decodeDataUrl(source);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
      );
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
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
