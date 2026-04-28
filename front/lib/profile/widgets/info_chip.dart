import 'package:flutter/material.dart';

Widget infoChip(IconData icon, String label) {
  return Row(
    children: [
      Icon(icon, size: 12, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 11,
        ),
      ),
    ],
  );
}
