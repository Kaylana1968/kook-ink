import 'package:flutter/material.dart';
import 'package:front/component/footer.dart';
import 'package:front/component/header.dart';

class Layout extends StatelessWidget {
  final Widget child;
  final String title;

  const Layout({super.key, required this.child, this.title = "My App"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(),
          Expanded(child: child),
          const Footer(),
        ],
      ),
    );
  }
}
