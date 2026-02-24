import 'package:flutter/material.dart';

// Widget pour UNE conversation/message
class MessageItem extends StatelessWidget {
  final String name;           // Nom de l'expéditeur
  final String message;        // Aperçu du message
  final String time;           // Heure/date
  final int unreadCount;       // 0 = lu, >0 = non lu
  final bool isAdmin;          // True = icône bibliothèque
  final VoidCallback onTap;

  const MessageItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount = 0,
    this.isAdmin = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isAdmin 
                    ? const Color(0xFFE67E22)  // Orange pour admin
                    : const Color(0xFF2C3E50), // Bleu pour membre
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAdmin ? Icons.menu_book : Icons.person,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et heure
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: unreadCount > 0 
                              ? const Color(0xFF2C3E50)
                              : const Color(0xFF7F8C8D),
                          fontWeight: unreadCount > 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Message
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0 
                                ? const Color(0xFF2C3E50)
                                : const Color(0xFF7F8C8D),
                            fontWeight: unreadCount > 0 
                                ? FontWeight.w500 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      
                      // Badge non lu
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}