import 'package:flutter/material.dart';

class StatWidget extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const StatWidget({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );

    final paddedContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: content,
    );

    if (onTap == null) return paddedContent;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: paddedContent,
    );
  }
}
