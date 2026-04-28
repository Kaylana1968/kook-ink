import 'package:flutter/material.dart';
import 'recipe_text_field.dart';

class RecipeStepsSection extends StatelessWidget {
  final List<TextEditingController> stepControllers;
  final VoidCallback onAddStep;
  final void Function(int index) onRemoveStep;

  const RecipeStepsSection({
    super.key,
    required this.stepControllers,
    required this.onAddStep,
    required this.onRemoveStep,
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
              "Étapes de préparation",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeColor,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAddStep,
              icon: const Icon(Icons.add, color: themeColor),
              label: const Text(
                "Ajouter",
                style: TextStyle(color: themeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(stepControllers.length, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14, right: 12),
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: stepControllers[index],
                    decoration: const InputDecoration(
                      hintText: "Décrivez cette étape ...",
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: stepControllers.length > 1
                    ? () => onRemoveStep(index)
                    : null,
              ),
            ],
          );
        }),
      ],
    );
  }
}
