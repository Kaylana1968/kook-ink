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
                leading: const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 20),
                ),
                title: Text(item["description"] ?? "Post sans description"),
                subtitle: Text(item["username"] ?? "Utilisateur"),
              );
            }

            // RECIPE
            if (type == "recipe") {
              final imageUrl = item["image_link"]?.toString() ?? "";

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant_outlined),
                            );
                          },
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant_outlined),
                        ),
                ),
                title: Text(
                  item["name"] ?? "Recette",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${item["preparation_time"] ?? 0} min • "
                    "${item["person"] ?? 0} pers.\n"
                    "${item["username"] ?? "Utilisateur"}"),
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}
