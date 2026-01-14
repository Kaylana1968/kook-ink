import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController difficultyController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController videoController = TextEditingController();

  bool isLoading = false;

  Future<void> envoyerRecette() async {
    setState(() => isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("http://127.0.0.1:8000/recipe"),
      );

      request.fields['description'] = descriptionController.text;
      request.fields['difficulty'] = difficultyController.text;
      request.fields['image_link'] = imageController.text;
      request.fields['video_link'] = videoController.text;
      request.fields['user_id'] = '2';

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette crée avec succès")),
        );

        descriptionController.clear();
        difficultyController.clear();
        imageController.clear();
        videoController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer une recette"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: difficultyController,
                decoration: const InputDecoration(
                  labelText: "Difficulté (1-5)",
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Lien image"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: videoController,
                decoration: const InputDecoration(labelText: "Lien vidéo"),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : envoyerRecette,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Créer la recette"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
