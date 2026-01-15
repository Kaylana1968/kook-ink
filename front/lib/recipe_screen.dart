import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Color themeColor = Color.fromARGB(251, 248, 165, 87);

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

  List<IngredientInput> ingredients = [IngredientInput()];
  List<TextEditingController> stepControllers = [TextEditingController()];

  bool isLoading = false;

  Future<void> sendRecipeForm() async {
    setState(() => isLoading = true);

    try {
      final steps = stepControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/recipe'),
        headers: {'Content-Type': 'application/json'},
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
          "user_id": 1,
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

  Widget champ(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? type,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 247, 246),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            champ(
              "Ajouter une image *",
              imageLinkController,
              hint: "URL de l’image",
            ),
            champ(
              "Ajouter une vidéo",
              videoLinkController,
              hint: "URL de la vidéo",
            ),
            champ(
              "Nom *",
              nameController,
              hint: "Ex: Lasagne",
            ),
            champ(
              "Astuce",
              tipsController,
              hint: "Ex: Rajouter du sel",
            ),
            champ(
              "Difficulté (1-5) *",
              difficultyController,
              type: TextInputType.number,
              hint: "Ex: 2",
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PREPARATION
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              color: Colors.black, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Préparation *",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: preparationTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Ex: 30 min",
                          hintStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CUISSON
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_fire_department_outlined,
                              color: Colors.black, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Cuisson *",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: bakingTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Ex: 30 min",
                          hintStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PORTIONS
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.group_outlined,
                              color: Colors.black, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Portions *",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: personController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Ex: 4",
                          hintStyle:
                              TextStyle(fontSize: 12, color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: themeColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            // ÉTAPES
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      "Étapes de préparation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          stepControllers.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add, color: themeColor),
                      label: const Text(
                        "Ajouter",
                        style: TextStyle(color: themeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  stepControllers.length,
                  (index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14, right: 12),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextField(
                              controller: stepControllers[index],
                              decoration: const InputDecoration(
                                hintText: "Décrivez cette étape ...",
                                hintStyle:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: themeColor, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: themeColor, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.black),
                          onPressed: stepControllers.length > 1
                              ? () => setState(
                                  () => stepControllers.removeAt(index))
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // INGRÉDIENTS
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      "Ingrédients",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          ingredients.add(IngredientInput());
                        });
                      },
                      icon: const Icon(Icons.add, color: themeColor),
                      label: const Text(
                        "Ajouter",
                        style: TextStyle(color: themeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...List.generate(
                  ingredients.length,
                  (index) {
                    final ingredient = ingredients[index];

                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Nom *",
                                  style: TextStyle(
                                    fontSize: 13,
                                  )),
                              const SizedBox(height: 6),
                              TextField(
                                controller: ingredient.name,
                                decoration: const InputDecoration(
                                  hintText: "Ex: Chocolat",
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Quantité *",
                                  style: TextStyle(
                                    fontSize: 13,
                                  )),
                              const SizedBox(height: 6),
                              TextField(
                                controller: ingredient.quantity,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Ex: 3",
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "",
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: ingredient.unit,
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: themeColor, width: 1),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: "u",
                                      child: Text(
                                        "Unité",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                  DropdownMenuItem(
                                      value: "g",
                                      child: Text(
                                        "g",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                  DropdownMenuItem(
                                      value: "kg",
                                      child: Text(
                                        "kg",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                  DropdownMenuItem(
                                      value: "mL",
                                      child: Text(
                                        "mL",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                  DropdownMenuItem(
                                      value: "L",
                                      child: Text(
                                        "L",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    ingredient.unit = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.black),
                            onPressed: ingredients.length > 1
                                ? () =>
                                    setState(() => ingredients.removeAt(index))
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // BOUTON
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendRecipeForm,
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: themeColor, width: 1),
                  backgroundColor: const Color.fromARGB(255, 248, 247, 246),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Créer la recette",
                        style: TextStyle(color: themeColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
