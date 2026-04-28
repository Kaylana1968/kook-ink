import 'package:flutter/material.dart';

import 'services/profile_api_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/post_profile_list.dart';
import 'widgets/recipe_profile_list.dart';
import 'widgets/favoris_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<dynamic>> _recipeFuture = Future.value([]);
  Future<List<dynamic>> _postFuture = Future.value([]);

  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _postFuture = ProfileApiService.fetchMyPosts();
    _recipeFuture = ProfileApiService.fetchRecipes();
    _loadFollowCount();
  }

  Future<void> _loadFollowCount() async {
    try {
      final data = await ProfileApiService.fetchFollowCount();

      if (!mounted) return;

      setState(() {
        followers = data["followers"] ?? 0;
        following = data["following"] ?? 0;
      });
    } catch (e) {
      print("Erreur follow count : $e");
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _postFuture = ProfileApiService.fetchMyPosts();
      _recipeFuture = ProfileApiService.fetchRecipes();
    });

    await Future.wait([
      _postFuture,
      _recipeFuture,
      _loadFollowCount(),
    ]);
  }

  void _openCreatePostModal() {
    final TextEditingController descriptionController = TextEditingController();

    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> sendPostForm() async {
              final description = descriptionController.text.trim();

              if (description.isEmpty) return;

              setModalState(() => isLoading = true);

              try {
                final success = await ProfileApiService.createPost(description);

                if (success) {
                  if (context.mounted) Navigator.pop(context);
                  await _refresh();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Post créé avec succès ✅"),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Erreur lors de la création du post"),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erreur : $e")),
                  );
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Erreur lors du chargement des posts"),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return const Center(child: Text("Aucun post"));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostProfileCard(
              post: posts[index],
              onRefresh: _refresh,
            );
          },
        );
      },
    );
  }

  Widget _recipesTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text("Erreur lors du chargement des recettes"),
          );
        }

        final recipes = snapshot.data ?? [];

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
          itemBuilder: (context, index) {
            return RecipeProfileCard(
              recipe: recipes[index],
              onRefresh: _refresh,
            );
          },
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeader(
                postFuture: _postFuture,
                followers: followers,
                following: following,
                onCreatePost: _openCreatePostModal,
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
