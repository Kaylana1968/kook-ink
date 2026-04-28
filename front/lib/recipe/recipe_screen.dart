import 'package:flutter/material.dart';

import 'models/ingredient_input.dart';
import 'services/recipe_api_service.dart';
import 'widgets/recipe_text_field.dart';
import 'widgets/recipe_time_fields.dart';
import 'widgets/recipe_steps_section.dart';
import 'widgets/recipe_ingredients_section.dart';

class RecipeScreen extends StatefulWidget {
  final Map<String, dynamic>? recipe;

  const RecipeScreen({
    super.key,
    this.recipe,
  });

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

  bool get isEditMode => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _fillFormIfEditing();
  }

  void _fillFormIfEditing() {
    if (!isEditMode) return;

    final recipe = widget.recipe!;

    nameController.text = recipe['name']?.toString() ?? '';
    tipsController.text = recipe['tips']?.toString() ?? '';
    difficultyController.text = recipe['difficulty']?.toString() ?? '';
    preparationTimeController.text =
        recipe['preparation_time']?.toString() ?? '';
    bakingTimeController.text = recipe['baking_time']?.toString() ?? '';
    personController.text = recipe['person']?.toString() ?? '';
    imageLinkController.text = recipe['image_link']?.toString() ?? '';
    videoLinkController.text = recipe['video_link']?.toString() ?? '';

    final steps = recipe['steps'] as List<dynamic>?;

    if (steps != null && steps.isNotEmpty) {
      stepControllers = steps
          .map((step) => TextEditingController(text: step.toString()))
          .toList();
    }

    final recipeIngredients = recipe['ingredients'] as List<dynamic>?;

    if (recipeIngredients != null && recipeIngredients.isNotEmpty) {
      ingredients = recipeIngredients.map((item) {
        final input = IngredientInput();
        input.name.text = item['name']?.toString() ?? '';
        input.quantity.text = item['quantity']?.toString() ?? '';
        input.unit = item['unit']?.toString() ?? 'u';
        return input;
      }).toList();
    }
  }

  Map<String, dynamic> _buildBody() {
    final steps = stepControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return {
      "name": nameController.text,
      "tips": tipsController.text.isEmpty ? null : tipsController.text,
      "difficulty": int.parse(difficultyController.text),
      "preparation_time": int.parse(preparationTimeController.text),
      "baking_time": int.parse(bakingTimeController.text),
      "person": int.parse(personController.text),
      "image_link":
          imageLinkController.text.isEmpty ? null : imageLinkController.text,
      "video_link":
          videoLinkController.text.isEmpty ? null : videoLinkController.text,
      "steps": steps,
      "ingredients":
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
    };
  }

  Future<void> sendRecipeForm() async {
    setState(() => isLoading = true);

    try {
      final body = _buildBody();

      final response = isEditMode
          ? await RecipeApiService.updateRecipe(widget.recipe!['id'], body)
          : await RecipeApiService.createRecipe(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        debugPrint("Erreur recette : ${response.statusCode}");
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint("Erreur recette : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    setState(() {
      stepControllers.removeAt(index);
    });
  }

  void _addIngredient() {
    setState(() {
      ingredients.add(IngredientInput());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void _changeIngredientUnit(int index, String value) {
    setState(() {
      ingredients[index].unit = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 254, 254),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RecipeTextField(
              label: "Ajouter une image *",
              controller: imageLinkController,
              hint: "URL de l’image",
            ),
            RecipeTextField(
              label: "Ajouter une vidéo",
              controller: videoLinkController,
              hint: "URL de la vidéo",
            ),
            RecipeTextField(
              label: "Nom *",
              controller: nameController,
              hint: "Ex: Lasagne",
            ),
            RecipeTextField(
              label: "Astuce",
              controller: tipsController,
              hint: "Ex: Rajouter du sel",
            ),
            RecipeTextField(
              label: "Difficulté (1-5) *",
              controller: difficultyController,
              type: TextInputType.number,
              hint: "Ex: 2",
            ),
            RecipeTimeFields(
              preparationController: preparationTimeController,
              bakingController: bakingTimeController,
              personController: personController,
            ),
            RecipeStepsSection(
              stepControllers: stepControllers,
              onAddStep: _addStep,
              onRemoveStep: _removeStep,
            ),
            RecipeIngredientsSection(
              ingredients: ingredients,
              onAddIngredient: _addIngredient,
              onRemoveIngredient: _removeIngredient,
              onUnitChanged: _changeIngredientUnit,
            ),
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
                    : Text(
                        isEditMode ? "Modifier la recette" : "Créer la recette",
                        style: const TextStyle(color: themeColor),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
