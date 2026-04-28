import 'package:flutter/material.dart';

const Color themeColor = Color.fromARGB(251, 248, 165, 87);

class RecipeTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? type;
  final String? hint;

  const RecipeTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.type,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: themeColor, width: 1),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: themeColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
