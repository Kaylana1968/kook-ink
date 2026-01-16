import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front/auth_service.dart';

// ------------------ API CONFIG ------------------
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri posts() => Uri.parse('$baseUrl/post');
}

// ------------------ PROFILE SCREEN ------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<dynamic>> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipes();
  }

  // ------------------ FETCH RECIPES ------------------
  Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(ApiConfig.recipes());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recipes'];
    } else {
      throw Exception('Erreur serveur');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _recipeFuture = fetchRecipes();
    });
  }

  // ------------------ CREATE POST ------------------
  Future<void> createPost(String description) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/post'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "description": description,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Post créé avec succès");
    } else {
      throw Exception("Erreur lors de la création du post");
    }
  }

// MODAL FORMULAIRE CREATION D'UN POST
  void _openCreatePostModal() {
    final TextEditingController descriptionController = TextEditingController();
    AuthService authService = AuthService();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> sendPostForm() async {
              final description = descriptionController.text.trim();
              if (description.isEmpty) return;

              setModalState(() => isLoading = true); // active le loader

              try {
                // Récupère le token depuis AuthService
                final token = await authService.getToken();

                final response = await http.post(
                  Uri.parse('http://127.0.0.1:8000/post'),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode({"description": description}),
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Post publié ✅")),
                  );
                  Navigator.pop(context);
                  _refresh(); // recharge la grille des recettes
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "Erreur lors de la publication ❌ : ${response.statusCode}")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur ❌ : $e")),
                );
              } finally {
                setModalState(() => isLoading = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Créer un post",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Écris une description...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : sendPostForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Publier"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------ BUILD ------------------
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(value: '12', label: 'Posts'),
                          _Stat(value: '340', label: 'Followers'),
                          _Stat(value: '180', label: 'Following'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BIO
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recettes simples / Fait maison',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              // BOUTONS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Modifier le profil'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openCreatePostModal,
                        child: const Text('Créer un post'),
                      ),
                    ),
                  ],
                ),
              ),

              // TABS
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: 'Post'),
                  Tab(text: 'Recettes'),
                  Tab(text: 'Favoris'),
                ],
              ),

              // TAB CONTENT
              SizedBox(
                height: 600,
                child: TabBarView(
                  children: [
                    _postsGrid(),
                    _recettesGrid3(),
                    _favorisList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ POSTS ------------------
  Widget _postsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, __) => Container(color: Colors.grey.shade300),
    );
  }

  // ------------------ RECETTES ------------------
  Widget _recettesGrid3() {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _refresh,
              child: const Text("Erreur - Réessayer"),
            ),
          );
        }

        final recipes = snapshot.data!;
        if (recipes.isEmpty) {
          return const Center(child: Text("Aucune recette"));
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(6),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IMAGE
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      recipe['image_link'] ?? 'https://via.placeholder.com/300',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOM
                        Text(
                          recipe['name'] ?? 'Sans nom',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // INFOS
                        _infoChip(Icons.timer_outlined,
                            "${recipe['preparation_time'] ?? 0} min"),
                        _infoChip(Icons.local_fire_department_outlined,
                            "${recipe['baking_time'] ?? 0} min"),
                        if (recipe['difficulty'] != null)
                          _infoChip(Icons.trending_up,
                              "Niv. ${recipe['difficulty']}"),
                        if (recipe['person'] != null)
                          _infoChip(Icons.people_outline,
                              "${recipe['person']} pers."),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ------------------ FAVORIS ------------------
  Widget _favorisList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: Icon(Icons.favorite, color: Colors.red),
          title: Text('Favori'),
        );
      },
    );
  }
}

// ------------------ STAT ------------------
class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
