import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

// Widget pour UN livre emprunté
class EmpruntCard extends StatelessWidget {
  final String title;
  final String author;
  final String returnDate;
  final bool isUrgent; // True = moins de 3 jours
  final String? coverUrl;
  final List<Color> gradientColors;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const EmpruntCard({
    super.key,
    required this.title,
    required this.author,
    required this.returnDate,
    required this.isUrgent,
    this.coverUrl,
    required this.gradientColors,
    this.primaryActionLabel = 'Voir le livre',
    this.secondaryActionLabel = 'Prolonger',
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Partie haute : image + infos
          Row(
            children: [
              // Image du livre
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
                    // Date de retour avec couleur
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFF7F8C8D),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Retour: $returnDate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            // Rouge si urgent, vert sinon
                            color: isUrgent
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrimaryAction,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2C3E50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    primaryActionLabel,
                    style: TextStyle(color: Color(0xFF2C3E50)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onSecondaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(secondaryActionLabel),
                ),
              ),
            ],
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
