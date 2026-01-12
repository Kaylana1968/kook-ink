import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const Footer({super.key, required this.currentIndex, required this.onItemSelected});

  Color _iconColor(int index) {
    return currentIndex == index
        ? const Color.fromARGB(251, 248, 165, 87)
        : const Color.fromARGB(255, 70, 70, 70);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 206, 206, 206),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home_outlined, size: 30, color: _iconColor(0)),
            onPressed: () => onItemSelected(0),
          ),
          IconButton(
            icon: Icon(Icons.search_outlined, size: 30, color: _iconColor(1)),
            onPressed: () => onItemSelected(1),
          ),
          IconButton(
            icon: Icon(Icons.web_stories_outlined, size: 30, color: _iconColor(2)),
            onPressed: () => onItemSelected(2),
          ),
          IconButton(
            icon: Icon(Icons.forum_outlined, size: 30, color: _iconColor(3)),
            onPressed: () => onItemSelected(3),
          ),
          IconButton(
            icon: Icon(Icons.person_outline, size: 30, color: _iconColor(4)),
            onPressed: () => onItemSelected(4),
          ),
        ],
      ),
    );
  }
}