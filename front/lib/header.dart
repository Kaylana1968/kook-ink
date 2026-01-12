import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final Function(int) onItemSelected;

  const Header({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 206, 206, 206),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/Logo.png',
                height: 50,
              ),
              const Text(
                'KOOK INK',
                style: TextStyle(
                  color: Color.fromARGB(251, 248, 165, 87),
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    size: 30, color: Color.fromARGB(255, 70, 70, 70)),
                onPressed: () => onItemSelected(5),
              ),
              IconButton(
                icon: const Icon(Icons.mode_comment_outlined,
                    size: 25, color: Color.fromARGB(255, 70, 70, 70)),
                onPressed: () => onItemSelected(6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
