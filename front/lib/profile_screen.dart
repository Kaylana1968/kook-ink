import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front/auth_service.dart';

// API CONFIG
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri posts() => Uri.parse('$baseUrl/post');
}

// PROFILE SCREEN
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<dynamic>> _recipeFuture = Future.value([]);
  Future<List<dynamic>> _postFuture = Future.value([]);
  int? _postCount;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipes();
    _postFuture = fetchPosts();
  }

  /// FETCH POSTS
  Future<List<dynamic>> fetchPosts() async {
    final response = await http
        .get(ApiConfig.posts(), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final posts = data['posts'] as List<dynamic>;

      setState(() {
        _postCount = posts.length;
      });

      return posts;
    } else {
      throw Exception('Erreur serveur');
    }
  }

  // FETCH RECIPES
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
      _postFuture = fetchPosts();
      _recipeFuture = fetchRecipes();
    });
  }

  // CREATE POST MODAL
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

              setModalState(() => isLoading = true);

              try {
                final token = await authService.getToken();

                final response = await http.post(
                  ApiConfig.posts(),
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $token",
                  },
                  body: jsonEncode({"description": description}),
                );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  Navigator.pop(context);
                  _refresh();
                }
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
                      child: isLoading
                          ? const CircularProgressIndicator()
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

  // BUILD
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleAvatar(radius: 40),
                    _PostCountWidget(postFuture: _postFuture),
                    const _Stat(value: '340', label: 'Followers'),
                    const _Stat(value: '180', label: 'Following'),
                  ],
                ),
              ),

              /// BUTTONS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _openCreatePostModal,
                        child: const Text('Créer un post'),
                      ),
                    ),
                  ],
                ),
              ),

              /// TABS
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: 'Post'),
                  Tab(text: 'Recettes'),
                  Tab(text: 'Favoris'),
                ],
              ),

              SizedBox(
                height: 600,
                child: TabBarView(
                  children: [
                    _postsTab(),
                    _recipesTab(),
                    const FavorisList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // POSTS TAB
  Widget _postsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(child: Text("Aucun post"));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => PostProfile(post: posts[index]),
        );
      },
    );
  }

  // RECIPES TAB
  Widget _recipesTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final recipes = snapshot.data!;
        if (recipes.isEmpty) {
          return const Center(child: Text("Aucune recette"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) => RecipeCard(recipe: recipes[index]),
        );
      },
    );
  }
}

// POST CLASS
class PostProfile extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostProfile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(post['description'] ?? ''),
          trailing: const Icon(Icons.more_horiz),
        ),
        const Divider(),
      ],
    );
  }
}

// RECIPE CLASS
class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              recipe['image_link'],
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
                // NOM RECETTE
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

                // ICONES INFOS
                _infoChip(
                  Icons.timer_outlined,
                  "${recipe['preparation_time'] ?? 0} min",
                ),
                _infoChip(
                  Icons.local_fire_department_outlined,
                  "${recipe['baking_time'] ?? 0} min",
                ),
                if (recipe['difficulty'] != null)
                  _infoChip(
                    Icons.trending_up,
                    "Niv. ${recipe['difficulty']}",
                  ),
                if (recipe['person'] != null)
                  _infoChip(
                    Icons.people_outline,
                    "${recipe['person']} pers.",
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FAVORIS CLASS
class FavorisList extends StatelessWidget {
  const FavorisList({super.key});

  @override
  Widget build(BuildContext context) {
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

// STAT
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

// STYLE ICONS
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

// COUNT
class _PostCountWidget extends StatelessWidget {
  final Future<List<dynamic>> postFuture;
  const _PostCountWidget({required this.postFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: postFuture,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) count = snapshot.data!.length;

        return _Stat(value: count.toString(), label: 'Posts');
      },
    );
  }
}
