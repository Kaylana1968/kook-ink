import 'package:flutter/material.dart';

class IngredientInput {
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  String unit = "u";

  Map<String, dynamic> toJson() {
    return {
      "name": name.text.trim(),
      "quantity": double.parse(
        quantity.text.trim().replaceAll(',', '.'),
      ),
      "unit": unit,
    };
  }
}
