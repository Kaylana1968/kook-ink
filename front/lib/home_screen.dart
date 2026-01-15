import 'package:flutter/material.dart';
import 'package:front/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoginForm(),
    );
  }
}
