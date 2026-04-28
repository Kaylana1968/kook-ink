import 'package:flutter/material.dart';

class StatWidget extends StatelessWidget {
  final String value;
  final String label;

  const StatWidget({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
