import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/auth_service.dart';
import 'package:http/http.dart' as http;
import '../services/profile_api_service.dart';

class PostProfileCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onRefresh;

  const PostProfileCard({
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

    final success = await ProfileApiService.deletePost(postId);

    if (success) {
      await onRefresh();
      print("Post supprimé");
    } else {
      print("Erreur suppresion post");
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
      ProfileApiService.postById(post['id']),
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
      print("Post modifié");
    } else {
      print("Erreur modification");
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
