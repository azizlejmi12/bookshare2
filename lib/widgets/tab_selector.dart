import 'package:flutter/material.dart';

// Widget pour les onglets (En cours / Historique)
class TabSelector extends StatelessWidget {
  final List<String> tabs;      // ['En cours', 'Historique']
  final int selectedIndex;      // 0 ou 1
  final Function(int) onTap;    // Action quand on clique

  const TabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected 
                          ? const Color(0xFF2C3E50) 
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? const Color(0xFF2C3E50) 
                        : const Color(0xFF7F8C8D),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}