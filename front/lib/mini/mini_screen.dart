import 'package:flutter/material.dart';

class MiniScreen extends StatelessWidget {
  const MiniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mini',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
