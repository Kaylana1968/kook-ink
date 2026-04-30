import 'package:flutter/material.dart';
import 'package:front/forum/services/forum_api_service.dart';
import 'package:front/forum/widgets/question_card.dart';
import 'package:go_router/go_router.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final ForumService _forumService = ForumService();
  late Future<List<dynamic>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _forumService.getAllPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = _forumService.getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    const orangeKook = Colors.orange;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        color: orangeKook,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearch(),
              const SizedBox(height: 20),
              _buildPosts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const orangeKook = Colors.orange;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Forum',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.push('/forum/post');
            _refreshPosts();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeKook,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Poser une question',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    const orangeKook = Colors.orange;

    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: orangeKook),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: orangeKook),
        ),
      ),
    );
  }

  Widget _buildPosts() {
    const orangeKook = Colors.orange;

    return FutureBuilder<List<dynamic>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: orangeKook),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Erreur : ${snapshot.error}"),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("Aucune question pour le moment."),
          );
        }

        final posts = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return QuestionCard(
              id: post['id'],
              nbReponses: post['responses_count'] ?? 0,
              titre: post['title'] ?? "Sans titre",
              contenu: post['description'] ?? "",
              username: post['username'] ??
                  post['user']?['username'] ??
                  "Utilisateur",
            );
          },
        );
      },
    );
  }
}
