import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // hauteur fixe pour le footer
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined,
                size: 30, color: Color.fromARGB(255, 70, 70, 70)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined,
                size: 30, color: Color.fromARGB(255, 70, 70, 70)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.web_stories_outlined,
                size: 30, color: Color.fromARGB(255, 70, 70, 70)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.forum_outlined,
                size: 30, color: Color.fromARGB(255, 70, 70, 70)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline,
                size: 30, color: Color.fromARGB(255, 70, 70, 70)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
