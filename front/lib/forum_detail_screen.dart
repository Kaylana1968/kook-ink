import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color orangeKook = Color(0xFFFF8A00);

class ForumDetailScreen extends StatefulWidget {
  final int postId;
  final String title;

  const ForumDetailScreen({
    super.key,
    required this.postId,
    required this.title,
  });

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchPostDetail();
  }

  Future<Map<String, dynamic>> _fetchPostDetail() async {
    // Note : Crée cette route dans FastAPI (voir mon message précédent)
    final response = await http.get(Uri.parse("http://10.0.2.2:8000/forum/posts/${widget.postId}"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur de chargement du détail');
    }
  }

  Future<void> _submitResponse() async {
    if (_commentController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/forum/posts/${widget.postId}/responses"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "content": _commentController.text,
        "user_id": 1, // Temporaire : à remplacer par l'ID de l'utilisateur connecté
      }),
    );

    if (response.statusCode == 200) {
      _commentController.clear();
      setState(() { _detailFuture = _fetchPostDetail(); }); // Rafraîchit la liste
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Question", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: orangeKook));
          }
          if (snapshot.hasError) return Center(child: Text("Erreur : ${snapshot.error}"));

          final data = snapshot.data!;
          final responses = data['responses'] as List;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(data['description'], style: const TextStyle(color: Colors.black87, height: 1.4)),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: responses.length,
                  itemBuilder: (context, index) {
                    final resp = responses[index];
                    return responseTile(resp['author'], resp['content'], resp['upvotes'] ?? 0);
                  },
                ),
              ),
              commentInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget responseTile(String author, String content, int upvotes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.person, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_up, color: orangeKook, size: 28),
                    Text("$upvotes", style: const TextStyle(fontWeight: FontWeight.bold, color: orangeKook)),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 28),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget commentInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Ajouter une réponse...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: orangeKook)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: orangeKook, width: 2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: orangeKook,
            child: IconButton(
              onPressed: _submitResponse,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}