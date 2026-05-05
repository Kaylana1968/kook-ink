import 'package:flutter/material.dart';

class ForumResponseInfo extends StatelessWidget {
  final int count;

  const ForumResponseInfo({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mode_comment_outlined,
          size: 18,
          color: Colors.black87,
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
