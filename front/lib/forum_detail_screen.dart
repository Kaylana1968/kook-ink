import 'package:flutter/material.dart';
import 'package:front/forum/forum_service.dart';

const Color orangeKook = Colors.orange;

class ForumDetailScreen extends StatefulWidget {
  final int postId;
  final String title;

  const ForumDetailScreen({super.key, required this.postId, required this.title});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final ForumService _forumService = ForumService();
  final TextEditingController _commentController = TextEditingController();
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _forumService.getPostDetail(widget.postId);
  }

  void _refresh() => setState(() {
        _detailFuture = _forumService.getPostDetail(widget.postId);
      });

  Future<void> _submitResponse() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _forumService.createResponse(
        postId: widget.postId,
        content: text,
      );
      _commentController.clear();
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _handleUpvote(int responseId) async {
    try {
      await _forumService.toggleUpvote(responseId: responseId);
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur upvote : $e')));
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
        title: const Text("Question",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: orangeKook));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final responses = data['responses'] as List;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'],
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(data['description'],
                        style: const TextStyle(
                            color: Colors.black87, height: 1.4)),
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
                    return _ResponseTile(
                      id: resp['id'],
                      author: resp['author'],
                      content: resp['content'],
                      upvotes: resp['upvotes'] ?? 0,
                      onUpvote: () => _handleUpvote(resp['id']),
                    );
                  },
                ),
              ),
              _commentInputBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _commentInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Ajouter une réponse...",
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: orangeKook)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: orangeKook, width: 2)),
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

class _ResponseTile extends StatelessWidget {
  final int id;
  final String author;
  final String content;
  final int upvotes;
  final VoidCallback onUpvote;

  const _ResponseTile({
    required this.id,
    required this.author,
    required this.content,
    required this.upvotes,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.person, color: Colors.grey)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(content,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onUpvote,
                      child: const Icon(Icons.keyboard_arrow_up,
                          color: orangeKook, size: 28),
                    ),
                    Text("$upvotes",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: orangeKook)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}