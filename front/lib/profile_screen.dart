import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/recipe_screen.dart';
import 'package:front/login_screen.dart';

// API CONFIG
class ApiConfig {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri recipes() => Uri.parse('$baseUrl/recipe');
  static Uri recipeById(dynamic id) => Uri.parse('$baseUrl/recipe/$id');

  static Uri posts() => Uri.parse('$baseUrl/post');
  static Uri postById(dynamic id) => Uri.parse('$baseUrl/post/$id');

  static Uri followCount() => Uri.parse('$baseUrl/follow/count');
}

// PROFILE SCREEN
class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<dynamic>> _recipeFuture = Future.value([]);
  Future<List<dynamic>> _postFuture = Future.value([]);
  final AuthService authService = AuthService();

  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipes();
    _postFuture = fetchPosts();
    fetchFollowCount();
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(
      ApiConfig.posts(),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['posts'] as List<dynamic>;
    } else {
      throw Exception('Erreur serveur posts');
    }
  }

  Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(ApiConfig.recipes());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recipes'] as List<dynamic>;
    } else {
      throw Exception('Erreur serveur recettes');
    }
  }

  Future<void> fetchFollowCount() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      ApiConfig.followCount(),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        followers = data['followers'];
        following = data['following'];
      });
    } else {
      print("Erreur follow count : ${response.statusCode}");
      print(response.body);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _postFuture = fetchPosts();
      _recipeFuture = fetchRecipes();
    });

    await _postFuture;
    await _recipeFuture;
    await fetchFollowCount();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    
    widget.onLogout(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Déconnexion réussie")),
      );
    }
  }

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
                  if (context.mounted) Navigator.pop(context);
                  await _refresh();
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
          itemBuilder: (context, index) => PostProfile(
            post: posts[index],
            onRefresh: _refresh,
          ),
        );
      },
    );
  }

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
          itemBuilder: (context, index) => RecipeCard(
            recipe: recipes[index],
            onRefresh: _refresh,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("Kook Ink test user", style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: _logout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const CircleAvatar(radius: 40),
                    _PostCountWidget(postFuture: _postFuture),
                    _Stat(value: followers.toString(), label: 'Followers'),
                    _Stat(value: following.toString(), label: 'Following'),
                  ],
                ),
              ),
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
}

// POST CLASS
class PostProfile extends StatelessWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onRefresh;

  const PostProfile({
    super.key,
    required this.post,
    required this.onRefresh,
  });

  Future<void> _deletePost(BuildContext context) async {
    final postId = post['id'];
    if (postId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce post ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await AuthService().getToken();

    final response = await http.delete(
      ApiConfig.postById(postId),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post supprimé")),
        );
      }
    }
  }

  Future<void> _editPost(BuildContext context) async {
    final TextEditingController controller = TextEditingController(
      text: post['description'] ?? '',
    );

    final newDescription = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le post'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (newDescription == null || newDescription.isEmpty) return;

    final token = await AuthService().getToken();

    final response = await http.put(
      ApiConfig.postById(post['id']),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'description': newDescription,
      }),
    );

    if (response.statusCode == 200) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post modifié')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(post['description'] ?? ''),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await _editPost(context);
              } else if (value == 'delete') {
                await _deletePost(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Modifier'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer'),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

// RECIPE CLASS
class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final Future<void> Function() onRefresh;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onRefresh,
  });

  String _getImageUrl() {
    final rawImageUrl = recipe['image_link']?.toString() ?? '';

    if (rawImageUrl.isEmpty) return '';

    if (rawImageUrl.startsWith('http')) {
      return rawImageUrl;
    }

    if (rawImageUrl.startsWith('/')) {
      return '${ApiConfig.baseUrl}$rawImageUrl';
    }

    return '${ApiConfig.baseUrl}/$rawImageUrl';
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    final recipeId = recipe['id'];
    if (recipeId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer cette recette ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await AuthService().getToken();

    final response = await http.delete(
      ApiConfig.recipeById(recipeId),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette supprimée")),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur suppression : ${response.statusCode}"),
          ),
        );
      }
    }
  }

  Future<void> _editRecipe(BuildContext context) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(recipe: recipe),
      ),
    );

    if (updated == true) {
      await onRefresh();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recette modifiée")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _getImageUrl();
    final hasValidImage = imageUrl.isNotEmpty &&
        Uri.tryParse(imageUrl) != null &&
        Uri.parse(imageUrl).hasScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: hasValidImage
                    ? Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  await _editRecipe(context);
                } else if (value == 'delete') {
                  await _deleteRecipe(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FAVORIS
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

  const _Stat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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

// COUNT POSTS
class _PostCountWidget extends StatelessWidget {
  final Future<List<dynamic>> postFuture;

  const _PostCountWidget({
    required this.postFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: postFuture,
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          count = snapshot.data!.length;
        }

        return _Stat(
          value: count.toString(),
          label: 'Posts',
        );
      },
    );
  }
}
