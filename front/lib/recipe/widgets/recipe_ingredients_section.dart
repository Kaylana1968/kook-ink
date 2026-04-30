import 'package:flutter/material.dart';
import '../models/ingredient_input.dart';
import 'recipe_text_field.dart';
import 'package:flutter/services.dart';

class RecipeIngredientsSection extends StatelessWidget {
  final List<IngredientInput> ingredients;
  final VoidCallback onAddIngredient;
  final void Function(int index) onRemoveIngredient;
  final void Function(int index, String value) onUnitChanged;

  const RecipeIngredientsSection({
    super.key,
    required this.ingredients,
    required this.onAddIngredient,
    required this.onRemoveIngredient,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              "Ingrédients",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeColor,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAddIngredient,
              icon: const Icon(Icons.add, color: themeColor),
              label: const Text(
                "Ajouter",
                style: TextStyle(color: themeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(ingredients.length, (index) {
          final ingredient = ingredients[index];

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: RecipeTextField(
                  label: "Nom *",
                  controller: ingredient.name,
                  hint: "Ex: Chocolat",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: RecipeTextField(
                  label: "Quantité *",
                  controller: ingredient.quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  hint: "Ex: 3 ou 2,5",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      const SizedBox(height: 19),
                      DropdownButtonFormField<String>(
                        value: ingredient.unit,
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: "u", child: Text("Unité")),
                          DropdownMenuItem(value: "g", child: Text("g")),
                          DropdownMenuItem(value: "kg", child: Text("kg")),
                          DropdownMenuItem(value: "mL", child: Text("mL")),
                          DropdownMenuItem(value: "L", child: Text("L")),
                        ],
                        onChanged: (value) {
                          if (value != null) onUnitChanged(index, value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: ingredients.length > 1
                      ? () => onRemoveIngredient(index)
                      : null,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
