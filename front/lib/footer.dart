import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color.fromARGB(255, 206, 206, 206),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search_outlined, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_outlined,
                size: 35,
                color: Color.fromARGB(
                  251,
                  248,
                  165,
                  87,
                )),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.web_stories_outlined, size: 30),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 30),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
