import 'package:flutter/material.dart';

Widget infoChip(IconData icon, String label) {
  return Row(
    children: [
      Icon(icon, size: 14, color: Colors.black),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}
