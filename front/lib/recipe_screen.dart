import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/auth_service.dart';
import 'package:http/http.dart' as http;

class IngredientInput {
  TextEditingController name = TextEditingController();
  TextEditingController quantity = TextEditingController();
  String unit = "u";

  Map<String, dynamic> toJson() => {
        "name": name.text,
        "quantity": double.parse(quantity.text),
        "unit": unit,
      };
}

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final nameController = TextEditingController();
  final tipsController = TextEditingController();
  final difficultyController = TextEditingController();
  final preparationTimeController = TextEditingController();
  final bakingTimeController = TextEditingController();
  final personController = TextEditingController();
  final imageLinkController = TextEditingController();
  final videoLinkController = TextEditingController();
  List<IngredientInput> ingredients = [
    IngredientInput(),
  ];
  List<TextEditingController> stepControllers = [
    TextEditingController(),
  ];
  AuthService authService = AuthService();

  bool isLoading = false;

  Future<void> sendRecipeForm() async {
    setState(() => isLoading = true);

    try {
      final steps = stepControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      String? token = await authService.getToken();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/recipe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": nameController.text,
          "tips": tipsController.text,
          "difficulty": int.parse(difficultyController.text),
          "preparation_time": int.parse(preparationTimeController.text),
          "baking_time": int.parse(bakingTimeController.text),
          "person": int.parse(personController.text),
          "image_link": imageLinkController.text.isEmpty
              ? null
              : imageLinkController.text,
          "video_link": videoLinkController.text.isEmpty
              ? null
              : videoLinkController.text,
          "steps": steps,
          "ingredients": ingredients.map((i) => i.toJson()).toList(),
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette créée avec succès")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la création")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget champ(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            champ("Lien image", imageLinkController),
            champ("Lien vidéo (optionnel)", videoLinkController),
            champ("Nom", nameController),
            champ("Astuce", tipsController),
            champ("Difficulté (1-5)", difficultyController,
                type: TextInputType.number),
            champ("Temps de préparation", preparationTimeController,
                type: TextInputType.number),
            champ("Temps de cuisson", bakingTimeController,
                type: TextInputType.number),
            champ("Nombre de personnes", personController,
                type: TextInputType.number),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Étapes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(stepControllers.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextField(
                            controller: stepControllers[index],
                            decoration: InputDecoration(
                              labelText: "Étape ${index + 1}",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: stepControllers.length > 1
                            ? () {
                                setState(() {
                                  stepControllers.removeAt(index);
                                });
                              }
                            : null,
                      ),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      stepControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter une étape"),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ingrédients",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(ingredients.length, (index) {
                  final ingredient = ingredients[index];

                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: ingredient.name,
                          decoration: const InputDecoration(labelText: "Nom"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: ingredient.quantity,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Qté"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: ingredient.unit,
                          items: const [
                            DropdownMenuItem(value: "u", child: Text("unité")),
                            DropdownMenuItem(value: "g", child: Text("g")),
                            DropdownMenuItem(value: "kg", child: Text("kg")),
                            DropdownMenuItem(value: "mL", child: Text("mL")),
                            DropdownMenuItem(value: "L", child: Text("L")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              ingredient.unit = value!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: ingredients.length > 1
                            ? () => setState(() => ingredients.removeAt(index))
                            : null,
                      ),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      ingredients.add(IngredientInput());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Ajouter un ingrédient"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendRecipeForm,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Créer la recette"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
