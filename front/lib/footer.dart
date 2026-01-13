import 'package:flutter/material.dart';
import 'package:front/forum_screen.dart';
import 'package:front/home_screen.dart';
import 'package:front/mini_screen.dart';
import 'package:front/profile_screen.dart';
import 'package:front/search_screen.dart';

class Footer extends StatelessWidget {
  final Function(Widget) onItemSelected;
  final Widget currentPage;

  const Footer(
      {super.key, required this.currentPage, required this.onItemSelected});

  Color getIconColor(Widget page) {
    return currentPage == page
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
            icon: Icon(Icons.home_outlined,
                size: 30, color: getIconColor(const HomeScreen())),
            onPressed: () => onItemSelected(const HomeScreen()),
          ),
          IconButton(
            icon: Icon(Icons.search_outlined,
                size: 30, color: getIconColor(const SearchScreen())),
            onPressed: () => onItemSelected(const SearchScreen()),
          ),
          IconButton(
            icon: Icon(Icons.web_stories_outlined,
                size: 30, color: getIconColor(const MiniScreen())),
            onPressed: () => onItemSelected(const MiniScreen()),
          ),
          IconButton(
            icon: Icon(Icons.forum_outlined,
                size: 30, color: getIconColor(const ForumScreen())),
            onPressed: () => onItemSelected(const ForumScreen()),
          ),
          IconButton(
            icon: Icon(Icons.person_outline,
                size: 30, color: getIconColor(const ProfileScreen())),
            onPressed: () => onItemSelected(const ProfileScreen()),
          ),
        ],
      ),
    );
  }
}
