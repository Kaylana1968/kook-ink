import 'package:flutter/material.dart';
import 'recipe_text_field.dart';

class RecipeTimeFields extends StatelessWidget {
  final TextEditingController preparationController;
  final TextEditingController bakingController;
  final TextEditingController personController;

  const RecipeTimeFields({
    super.key,
    required this.preparationController,
    required this.bakingController,
    required this.personController,
  });

  Widget _smallField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _smallField(
          icon: Icons.timer_outlined,
          label: "Préparation *",
          hint: "Ex: 30 min",
          controller: preparationController,
        ),
        const SizedBox(width: 10),
        _smallField(
          icon: Icons.local_fire_department_outlined,
          label: "Cuisson *",
          hint: "Ex: 30 min",
          controller: bakingController,
        ),
        const SizedBox(width: 10),
        _smallField(
          icon: Icons.group_outlined,
          label: "Portion *",
          hint: "Ex: 4",
          controller: personController,
        ),
      ],
    );
  }
}
