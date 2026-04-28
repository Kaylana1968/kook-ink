import 'package:flutter/material.dart';
import 'package:front/auth_service.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<bool> checkLoginStatus() async {
    AuthService authService = AuthService();
    String? token = await authService.getToken(); // Assume this method exists
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    Color getIconColor(String route) {
      return ModalRoute.of(context)!.settings.name == route
          ? const Color.fromARGB(251, 248, 165, 87)
          : const Color.fromARGB(255, 70, 70, 70);
    }

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
            icon: Icon(Icons.home_outlined, size: 30, color: getIconColor("/")),
            onPressed: () => context.go("/"),
          ),
          IconButton(
            icon: Icon(Icons.search_outlined,
                size: 30, color: getIconColor("/search")),
            onPressed: () => context.go("/search"),
          ),
          IconButton(
            icon: Icon(Icons.add_outlined,
                size: 30, color: getIconColor("/recipe")),
            onPressed: () => context.go("/recipe"),
          ),
          IconButton(
            icon: Icon(Icons.web_stories_outlined,
                size: 30, color: getIconColor("/minis")),
            onPressed: () => context.go("/minis"),
          ),
          IconButton(
            icon: Icon(Icons.forum_outlined,
                size: 30, color: getIconColor("/forum")),
            onPressed: () => context.go("/forum"),
          ),
          IconButton(
            icon: Icon(Icons.person_outline,
                size: 30, color: getIconColor("/profile")),
            onPressed: () => context.go("/profile"),
          ),
        ],
      ),
    );
  }
}
