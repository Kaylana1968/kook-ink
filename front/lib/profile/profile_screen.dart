import 'package:flutter/material.dart';
import 'package:front/services/media_api_service.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/widgets/app_feedback.dart';
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
  int publicationsCount = 0;
  bool isFollowing = false;
  bool isFollowLoading = false;
  int _loadVersion = 0;

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

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId) {
      _loadData();
    }
  }

  //  LOAD POST, RECIPES, PROFILE
  void _loadData() {
    final loadVersion = ++_loadVersion;
    final Future<List<dynamic>> postFuture;
    final Future<List<dynamic>> recipeFuture;

    if (isMyProfile) {
      // MY PROFILE DATA
      postFuture = ProfileApiService.fetchMyPosts();
      recipeFuture = ProfileApiService.fetchMyRecipes();
    } else {
      // PROFILE DATA OTHER
      postFuture = ProfileApiService.fetchUserPosts(widget.userId!);
      recipeFuture = ProfileApiService.fetchUserRecipes(widget.userId!);
    }

    setState(() {
      _postFuture = postFuture;
      _recipeFuture = recipeFuture;
    });

    _loadProfileInfo(loadVersion);
    _loadPublicationsCount(postFuture, recipeFuture, loadVersion);
  }

  Future<void> _loadProfileInfo(int loadVersion) async {
    try {
      final results = await Future.wait([
        isMyProfile
            ? ProfileApiService.fetchMyProfile()
            : ProfileApiService.fetchUserProfile(widget.userId!),
        isMyProfile
            ? ProfileApiService.fetchFollowCount()
            : ProfileApiService.fetchUserFollowCount(widget.userId!),
        isMyProfile
            ? Future<bool>.value(false)
            : ProfileApiService.fetchFollowStatus(widget.userId!),
      ]);

      if (!mounted || loadVersion != _loadVersion) return;

      final profile = results[0] as Map<String, dynamic>;
      final followCount = results[1] as Map<String, int>;
      final followStatus = results[2] as bool;
      setState(() {
        username = profile["username"]?.toString() ?? "";
        description = profile["description"]?.toString() ?? "";
        followers = followCount["followers"] ?? 0;
        following = followCount["following"] ?? 0;
        isFollowing = followStatus;
      });
    } catch (e) {
      debugPrint("Erreur profil : $e");
    }
  }

  Future<void> _loadPublicationsCount(
    Future<List<dynamic>> postFuture,
    Future<List<dynamic>> recipeFuture,
    int loadVersion,
  ) async {
    try {
      final results = await Future.wait([postFuture, recipeFuture]);
      if (!mounted || loadVersion != _loadVersion) return;

      setState(() {
        publicationsCount = results[0].length + results[1].length;
      });
    } catch (e) {
      debugPrint("Erreur publications count : $e");
    }
  }

  // FOLLOW / UNFOLLOW
  Future<void> _toggleFollow() async {
    if (isMyProfile || isFollowLoading) return;

    setState(() {
      isFollowLoading = true;
    });

    try {
      final success = isFollowing
          ? await ProfileApiService.unfollow(widget.userId!)
          : await ProfileApiService.follow(widget.userId!);

      if (!mounted) return;

      if (!success) return;

      setState(() {
        final nextFollowing = !isFollowing;
        isFollowing = nextFollowing;
        followers += nextFollowing ? 1 : -1;
        if (followers < 0) followers = 0;
      });
      showAppFeedback(
        context,
        isFollowing ? "Utilisateur suivi" : "Abonnement retiré",
      );
    } catch (e) {
      if (mounted) {
        showAppFeedback(
          context,
          "Impossible de modifier l'abonnement : $e",
          isError: true,
        );
      }
      debugPrint("Erreur follow toggle : $e");
    } finally {
      if (mounted) {
        setState(() {
          isFollowLoading = false;
        });
      }
    }
  }

  Future<void> _openFollowList({
    required String title,
    required bool followersList,
  }) async {
    final profileContext = context;
    final usersFuture = followersList
        ? ProfileApiService.fetchFollowers(userId: widget.userId)
        : ProfileApiService.fetchFollowing(userId: widget.userId);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: FutureBuilder<List<dynamic>>(
            future: usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 220,
                  child: Center(child: Text(snapshot.error.toString())),
                );
              }

              final users = snapshot.data ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (users.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Text("Aucun utilisateur pour le moment."),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = users[index] as Map<String, dynamic>;
                          final userId = user["id"];
                          final username =
                              user["username"]?.toString() ?? "Utilisateur";

                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(username),
                            onTap: userId == null
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    final targetId =
                                        int.tryParse(userId.toString());
                                    if (targetId == null) return;

                                    if (isMyProfile ||
                                        targetId != widget.userId) {
                                      profileContext.go('/profile/$targetId');
                                    }
                                  },
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // LOAD DATA
  Future<void> _refresh() async {
    final loadVersion = ++_loadVersion;
    final Future<List<dynamic>> postFuture;
    final Future<List<dynamic>> recipeFuture;

    if (isMyProfile) {
      postFuture = ProfileApiService.fetchMyPosts();
      recipeFuture = ProfileApiService.fetchMyRecipes();
    } else {
      postFuture = ProfileApiService.fetchUserPosts(widget.userId!);
      recipeFuture = ProfileApiService.fetchUserRecipes(widget.userId!);
    }

    setState(() {
      _postFuture = postFuture;
      _recipeFuture = recipeFuture;
    });

    await Future.wait([
      _loadProfileInfo(loadVersion),
      _loadPublicationsCount(postFuture, recipeFuture, loadVersion),
    ]);
  }

  // MODAL CREATE POST
  void _openCreatePostModal() {
    final controller = TextEditingController();
    bool isLoading = false;
    bool isUploadingImage = false;
    String? imageLink;

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

              if (description.isEmpty) {
                showAppFeedback(
                  context,
                  "Le post ne peut pas être vide",
                  isError: true,
                );
                return;
              }

              setModalState(() {
                isLoading = true;
              });

              try {
                final success = await ProfileApiService.createPost(
                  description,
                  imageLink: imageLink,
                );

                if (success) {
                  showAppFeedback(context, "Post créé");
                  if (context.mounted) context.go('/profile');
                  await _refresh();
                  debugPrint("Post créé");
                } else {
                  showAppFeedback(
                    context,
                    "Impossible de créer le post",
                    isError: true,
                  );
                  debugPrint("Erreur création post");
                }
              } catch (e) {
                showAppFeedback(
                  context,
                  "Erreur réseau pendant la création du post : $e",
                  isError: true,
                );
              } finally {
                setModalState(() {
                  isLoading = false;
                });
              }
            }

            Future<void> pickAndUploadImage(ImageSource source) async {
              try {
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: source,
                  imageQuality: 85,
                  maxWidth: 1600,
                );

                if (image == null) return;

                setModalState(() {
                  isUploadingImage = true;
                });

                final uploadedUrl = await MediaApiService.uploadImage(image);

                setModalState(() {
                  imageLink = uploadedUrl;
                });
              } catch (e) {
                if (!context.mounted) return;

                showAppFeedback(
                  context,
                  "Erreur upload image : $e",
                  isError: true,
                );
              } finally {
                setModalState(() {
                  isUploadingImage = false;
                });
              }
            }

            return SingleChildScrollView(
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
                  if (imageLink != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageLink!,
                          height: 160,
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
                              : () => pickAndUploadImage(ImageSource.camera),
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: const Text("Photo"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isUploadingImage
                              ? null
                              : () => pickAndUploadImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text("Galerie"),
                        ),
                      ),
                    ],
                  ),
                  if (isUploadingImage)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(color: Colors.orange),
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
          return _emptyTab("Erreur chargement posts");
        }

        if (!snapshot.hasData) {
          return const _LoadingTab();
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return _emptyTab("Aucun post");
        }

        return ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostProfileCard(
              post: posts[index],
              onRefresh: _refresh,
              isMyPost: isMyProfile,
              username: username,
            );
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
          return _emptyTab("Erreur chargement recettes");
        }

        if (!snapshot.hasData) {
          return const _LoadingTab();
        }

        final recipes = snapshot.data!;

        if (recipes.isEmpty) {
          return _emptyTab("Aucune recette");
        }

        return GridView.builder(
          physics: const ClampingScrollPhysics(),
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
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.orange,
          child: Column(
            children: [
              ProfileHeader(
                publicationsCount: publicationsCount,
                followers: followers,
                following: following,
                username: username,
                description: description,
                onCreatePost: isMyProfile ? _openCreatePostModal : null,
                isFollowing: isFollowing,
                isFollowLoading: isFollowLoading,
                onToggleFollow: isMyProfile ? null : _toggleFollow,
                onFollowersTap: () => _openFollowList(
                  title: "Followers",
                  followersList: true,
                ),
                onFollowingTap: () => _openFollowList(
                  title: "Suivi(e)s",
                  followersList: false,
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
              Expanded(
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

Widget _emptyTab(String message) {
  return Center(child: Text(message));
}

class _LoadingTab extends StatelessWidget {
  const _LoadingTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
