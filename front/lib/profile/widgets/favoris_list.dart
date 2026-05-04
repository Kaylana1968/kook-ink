import 'package:flutter/material.dart';
import 'package:front/widgets/like_button.dart';
import '../services/profile_api_service.dart';

class FavorisList extends StatelessWidget {
  final int? userId;

  const FavorisList({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final future = userId == null
        ? ProfileApiService.fetchFavorites()
        : ProfileApiService.fetchUserFavorites(userId!);

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
            final likesCount =
                int.tryParse(item["likes_count"]?.toString() ?? "") ?? 0;
            final commentsCount =
                int.tryParse(item["comments_count"]?.toString() ?? "") ?? 0;

            if (type == "post") {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(item["description"] ?? "Post sans description"),
                subtitle: Text(
                  "${item["username"] ?? "Utilisateur"} - "
                  "$commentsCount commentaire${commentsCount > 1 ? 's' : ''}",
                ),
                trailing: item["id"] is int
                    ? LikeButton(
                        type: 'post',
                        itemId: item["id"],
                        compact: true,
                        initialCount: likesCount,
                      )
                    : null,
              );
            }

            if (type == "recipe") {
              return ListTile(
                leading: const Icon(Icons.restaurant_outlined),
                title: Text(item["name"] ?? "Recette"),
                subtitle: Text(
                  "${item["username"] ?? "Utilisateur"} - "
                  "${item["preparation_time"] ?? 0} min - "
                  "${item["person"] ?? 0} pers. - "
                  "$commentsCount commentaire${commentsCount > 1 ? 's' : ''}",
                ),
                trailing: item["id"] is int
                    ? LikeButton(
                        type: 'recipe',
                        itemId: item["id"],
                        compact: true,
                        initialCount: likesCount,
                      )
                    : null,
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}
