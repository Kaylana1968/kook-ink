import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'services/profile_api_service.dart';
import 'widgets/profile_header.dart';
import 'widgets/post_profile_list.dart';
import 'widgets/recipe_profile_list.dart';
import 'widgets/favoris_list.dart';

class ProfileScreen extends StatefulWidget {
  final int? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //  LOAD POST AND RECIPE
  Future<List<dynamic>> _postFuture = Future.value([]);
  Future<List<dynamic>> _recipeFuture = Future.value([]);

  // NUMBER OF FOLLOWERS
  int followers = 0;
  int following = 0;

  // INFO PROFILE
  String username = "";
  String description = "";

  // IT'S MY PROFILE ?
  bool get isMyProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();

    //LOAD DATA PAGE
    _loadData();
  }

  //  LOAD POST, RECIPES, PROFILE
  void _loadData() {
    if (isMyProfile) {
      // MY PROFILE DATA
      _postFuture = ProfileApiService.fetchMyPosts();
      _recipeFuture = ProfileApiService.fetchMyRecipes();
    } else {
      // PROFILE DATA OTHER
      _postFuture = ProfileApiService.fetchUserPosts(widget.userId!);
      _recipeFuture = ProfileApiService.fetchUserRecipes(widget.userId!);
    }

    _loadProfile();
    _loadFollowCount();
  }

  // LOAD PROFILE
  Future<void> _loadProfile() async {
    try {
      Map<String, dynamic> data;

      if (isMyProfile) {
        data = await ProfileApiService.fetchMyProfile();
      } else {
        data = await ProfileApiService.fetchUserProfile(widget.userId!);
      }

      if (!mounted) return;

      setState(() {
        username = data["username"]?.toString() ?? "";
        description = data["description"]?.toString() ?? "";
      });
    } catch (e) {
      debugPrint("Erreur profil : $e");
    }
  }

  // LOAD FOLLOW
  Future<void> _loadFollowCount() async {
    try {
      Map<String, int> data;

      if (isMyProfile) {
        data = await ProfileApiService.fetchFollowCount();
      } else {
        data = await ProfileApiService.fetchUserFollowCount(widget.userId!);
      }

      if (!mounted) return;

      setState(() {
        followers = data["followers"] ?? 0;
        following = data["following"] ?? 0;
      });
    } catch (e) {
      debugPrint("Erreur follow count : $e");
    }
  }

  // LOAD DATA
  Future<void> _refresh() async {
    setState(() {
      if (isMyProfile) {
        _postFuture = ProfileApiService.fetchMyPosts();
        _recipeFuture = ProfileApiService.fetchMyRecipes();
      } else {
        _postFuture = ProfileApiService.fetchUserPosts(widget.userId!);
        _recipeFuture = ProfileApiService.fetchUserRecipes(widget.userId!);
      }
    });

    await _postFuture;
    await _recipeFuture;
    await _loadProfile();
    await _loadFollowCount();
  }

  // MODAL CREATE POST
  void _openCreatePostModal() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
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
            Future<void> createPost() async {
              final description = controller.text.trim();

              if (description.isEmpty) return;

              setModalState(() {
                isLoading = true;
              });

              final success = await ProfileApiService.createPost(description);

              setModalState(() {
                isLoading = false;
              });

              if (success) {
                await _refresh();
                if (context.mounted) {
                  context.pop();
                }
                Fluttertoast.showToast(
                  msg: "Post créé",
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text("Erreur lors de la création du post"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
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
                    controller: controller,
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
                      onPressed: isLoading ? null : createPost,
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

  // POST TAB
  Widget _postsTab() {
    return FutureBuilder<List<dynamic>>(
      future: _postFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Erreur chargement posts"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return const Center(child: Text("Aucun post"));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostProfileCard(
                post: posts[index], onRefresh: _refresh, isMyPost: isMyProfile);
          },
        );
      },
    );
  }

  // RECIPE TAB
  Widget _recipesTab() {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Erreur chargement recettes"));
        }

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
            childAspectRatio: 0.7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            return RecipeProfileCard(
              recipe: recipes[index],
              onRefresh: _refresh,
              isMyRecipe: isMyProfile,
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
                recipeFuture: _recipeFuture,
                followers: followers,
                following: following,
                userId: widget.userId ?? 0,
                isMyProfile: isMyProfile,
                username: username,
                description: description,
                onCreatePost: isMyProfile ? _openCreatePostModal : null,
                onRefresh: _refresh,
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
                    FavorisList(userId: widget.userId),
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
