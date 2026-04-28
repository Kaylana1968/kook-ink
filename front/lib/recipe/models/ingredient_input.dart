import 'package:flutter/material.dart';

class IngredientInput {
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  String unit = "u";

  Map<String, dynamic> toJson() {
    final text = quantity.text.trim().replaceAll(',', '.');

    return {
      "name": name.text.trim(),
      "quantity": text.isEmpty ? 0 : double.parse(text),
      "unit": unit,
    };
  }
}
