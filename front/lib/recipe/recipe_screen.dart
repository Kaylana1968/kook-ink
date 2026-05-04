import 'package:flutter/material.dart';
import 'package:front/media_api_service.dart';
import 'package:front/recipe/models/api_exception.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'models/ingredient_input.dart';
import 'services/recipe_api_service.dart';
import 'widgets/recipe_text_field.dart';
import 'widgets/recipe_time_fields.dart';
import 'widgets/recipe_steps_section.dart';
import 'widgets/recipe_ingredients_section.dart';

class RecipeScreen extends StatefulWidget {
  final int? recipeId;

  const RecipeScreen({
    super.key,
    this.recipeId,
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
  bool isFetching = false;
  bool isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) {
      _fillFormIfEditing();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    tipsController.dispose();
    difficultyController.dispose();
    preparationTimeController.dispose();
    bakingTimeController.dispose();
    personController.dispose();
    imageLinkController.dispose();
    videoLinkController.dispose();
    for (var controller in stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fillFormIfEditing() async {
    setState(() => isFetching = true);

    try {
      final recipe = await RecipeApiService.getRecipe(widget.recipeId!);

      if (!mounted) return;

      setState(() {
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
      });
    } catch (e) {
      debugPrint("Error fetching recipe: $e");
    } finally {
      if (mounted) setState(() => isFetching = false);
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

  String? _validateForm() {
    if (nameController.text.trim().isEmpty) return "Le nom est requis";

    // Check numbers are valid numbers
    if (difficultyController.text.isEmpty ||
        int.tryParse(difficultyController.text) == null) {
      return "La difficulté est invalide";
    }
    if (preparationTimeController.text.isEmpty ||
        int.tryParse(preparationTimeController.text) == null) {
      return "Le temps de préparation est invalid";
    }
    if (bakingTimeController.text.isEmpty ||
        int.tryParse(bakingTimeController.text) == null) {
      return "Le temps de cuisson est invalid";
    }
    if (personController.text.isEmpty ||
        int.tryParse(personController.text) == null) {
      return "Le nombre de personnes est invalid";
    }

    // Check there is no empty step
    if (stepControllers.any((c) => c.text.trim().isEmpty)) {
      return "Supprimez les étapes vides";
    }
    // Check there is at least one step
    if (stepControllers.isEmpty) return "Ajoutez au moins une étape";

    // Check there is no empty ingredient name
    if (ingredients.any((ingredient) => ingredient.name.text.trim().isEmpty)) {
      return "Nommez tous les ingrédients";
    }
    // Check there is no empty or invalid ingredient quantity
    if (ingredients.any((ingredient) =>
        ingredient.quantity.text.trim().isEmpty ||
        int.tryParse(ingredient.quantity.text) == null)) {
      return "La quantité d'un ingrédient est invalide";
    }
    // Check there is at least one ingredient
    if (ingredients.isEmpty) {
      return "Ajoutez au moins un ingrédient";
    }

    return null;
  }

  Future<void> sendRecipeForm() async {
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final body = _buildBody();
      final int? recipeId = widget.recipeId;

      if (recipeId == null) {
        await RecipeApiService.createRecipe(body);
      } else {
        await RecipeApiService.updateRecipe(recipeId, body);
      }

      if (!mounted) return;
      context.go("/profile");
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur ${e.statusCode} : ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur réseau est survenue.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return;

      setState(() => isUploadingImage = true);
      final imageLink = await MediaApiService.uploadImage(image);

      if (!mounted) return;
      setState(() {
        imageLinkController.text = imageLink;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur upload image : $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isUploadingImage = false);
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
    if (isFetching) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 254, 254),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (imageLinkController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageLinkController.text,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploadingImage
                        ? null
                        : () => _pickAndUploadImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text("Photo"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isUploadingImage
                        ? null
                        : () => _pickAndUploadImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text("Galerie"),
                  ),
                ),
              ],
            ),
            if (isUploadingImage)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(color: Colors.orange),
              ),
            RecipeTextField(
              label: "Ajouter une image",
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
              label: "Difficulté",
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
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : Text(
                        widget.recipeId == null
                            ? "Créer la recette"
                            : "Modifier la recette",
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
