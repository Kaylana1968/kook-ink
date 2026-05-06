import 'package:flutter/material.dart';
import 'package:front/services/media_api_service.dart';
import 'package:front/recipe/models/api_exception.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'models/ingredient_input.dart';
import 'services/recipe_api_service.dart';
import 'package:front/widgets/app_feedback.dart';
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

  List<IngredientInput> ingredients = [IngredientInput()];
  List<TextEditingController> stepControllers = [TextEditingController()];

  bool isLoading = false;
  bool isFetching = false;
  bool isUploadingImage = false;

  bool get _isEditing => widget.recipeId != null;

  String _text(TextEditingController controller) => controller.text.trim();

  String? _optionalText(TextEditingController controller) {
    final value = _text(controller);
    return value.isEmpty ? null : value;
  }

  List<String> get _steps =>
      stepControllers.map(_text).where((step) => step.isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
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
            input.quantity.text =
                IngredientInput.formatQuantity(item['quantity']);
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
    return {
      "name": _text(nameController),
      "tips": _optionalText(tipsController),
      "difficulty": int.parse(_text(difficultyController)),
      "preparation_time": int.parse(_text(preparationTimeController)),
      "baking_time": int.parse(_text(bakingTimeController)),
      "person": int.parse(_text(personController)),
      "image_link": _optionalText(imageLinkController),
      "steps": _steps,
      "ingredients":
          ingredients.map((ingredient) => ingredient.toJson()).toList(),
    };
  }

  String? _validateForm() {
    if (_text(nameController).isEmpty) return "Le nom est requis";

    final numberError = _validateNumbers();
    if (numberError != null) return numberError;

    if (ingredients.isEmpty) {
      return "Ajoutez au moins un ingrédient";
    }
    if (ingredients.any((ingredient) => ingredient.name.text.trim().isEmpty)) {
      return "Nommez tous les ingrédients";
    }
    if (ingredients.any((ingredient) =>
        ingredient.quantity.text.trim().isEmpty ||
        !IngredientInput.isValidQuantity(ingredient.quantity.text))) {
      return "La quantité d'un ingrédient est invalide";
    }
    return null;
  }

  String? _validateNumbers() {
    final fields = [
      MapEntry(difficultyController, "La difficulté est invalide"),
      MapEntry(preparationTimeController, "Le temps de préparation est invalide"),
      MapEntry(bakingTimeController, "Le temps de cuisson est invalide"),
      MapEntry(personController, "Le nombre de personnes est invalide"),
    ];

    for (final field in fields) {
      if (int.tryParse(_text(field.key)) == null) return field.value;
    }

    return null;
  }

  void _showError(String message) {
    showAppFeedback(context, message, isError: true);
  }

  Future<void> sendRecipeForm() async {
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      _showError(errorMessage);
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
      showAppFeedback(
        context,
        recipeId == null ? "Recette créée" : "Recette modifiée",
      );
      context.go("/profile");
    } on ApiException catch (e) {
      if (!mounted) return;

      _showError('Erreur ${e.statusCode} : ${e.message}');
    } catch (e) {
      if (!mounted) return;

      _showError('Une erreur réseau est survenue.');
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

      _showError("Erreur upload image : Vérifiez votre connexion ou ressayez plus tard");
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
    final removedController = stepControllers[index];
    setState(() {
      stepControllers.removeAt(index);
    });
    removedController.dispose();
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        _isEditing
                            ? "Modifier la recette"
                            : "Créer la recette",
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
