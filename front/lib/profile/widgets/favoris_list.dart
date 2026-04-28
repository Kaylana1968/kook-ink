import 'package:flutter/material.dart';
import '../services/profile_api_service.dart';

class FavorisList extends StatelessWidget {
  final int? userId;

  const FavorisList({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> future;

    if (userId == null) {
      future = ProfileApiService.fetchFavorites();
    } else {
      future = ProfileApiService.fetchUserFavorites(userId!);
    }

    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Erreur lors du chargement des favoris"),
          );
        }

        // données
        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return const Center(
            child: Text("Aucun favori"),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final favorite = favorites[index];
            final type = favorite["type"];
            final item = favorite["item"];

            // POST
            if (type == "post") {
              return ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(item["description"] ?? "Post sans description"),
                subtitle: Text(item["username"] ?? "Utilisateur"),
              );
            }

            // RECETTE
            if (type == "recipe") {
              return ListTile(
                leading: const Icon(Icons.restaurant_outlined),
                title: Text(item["name"] ?? "Recette"),
                subtitle: Text(
                  "${item["username"] ?? "Utilisateur"} • "
                  "${item["preparation_time"] ?? 0} min • "
                  "${item["person"] ?? 0} pers.",
                ),
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}
