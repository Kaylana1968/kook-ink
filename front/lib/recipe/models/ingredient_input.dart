import 'package:flutter/material.dart';

class IngredientInput {
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  String unit = "u";

  static bool isValidQuantity(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    return normalizedValue.isNotEmpty &&
        double.tryParse(normalizedValue) != null;
  }

  static String formatQuantity(dynamic value) {
    if (value == null) return '';

    final text = value.toString().trim();
    final number = double.tryParse(text.replaceAll(',', '.'));
    if (number == null) return text;

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return text.replaceAll('.', ',');
  }

  Map<String, dynamic> toJson() {
    final text = quantity.text.trim().replaceAll(',', '.');

    return {
      "name": name.text.trim(),
      "quantity": text.isEmpty ? 0 : double.parse(text),
      "unit": unit,
    };
  }
}
