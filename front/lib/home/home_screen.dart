import 'package:flutter/material.dart';

import 'services/home_api_service.dart';
import 'widgets/feed_post_card.dart';
import 'widgets/feed_recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = HomeApiService.fetchFeed();
  }

  Future<void> _refresh() async {
    setState(() {
      _feedFuture = HomeApiService.fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final feed = snapshot.data ?? [];

        if (feed.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.orange,
          child: ListView.builder(
            itemCount: feed.length,
            itemBuilder: (context, index) {
              final feedItem = feed[index];

              if (feedItem["type"] == "post") {
                return FeedPostCard(post: feedItem["item"]);
              }

              if (feedItem["type"] == "recipe") {
                return FeedRecipeCard(recipe: feedItem["item"]);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(error),
          TextButton(
            onPressed: _refresh,
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Aucun contenu"),
    );
  }
}
