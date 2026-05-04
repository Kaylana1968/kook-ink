import 'package:flutter/material.dart';

class CommentSection extends StatefulWidget {
  final Future<List<dynamic>> Function() loadComments;
  final Future<void> Function(String content) onSubmit;
  final VoidCallback? onCommentCreated;
  final ScrollController? scrollController;
  final bool expand;

  const CommentSection({
    super.key,
    required this.loadComments,
    required this.onSubmit,
    this.onCommentCreated,
    this.scrollController,
    this.expand = false,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<dynamic>> _commentsFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _commentsFuture = widget.loadComments();
    });

    await _commentsFuture;
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await widget.onSubmit(text);
      _controller.clear();
      widget.onCommentCreated?.call();
      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsView = FutureBuilder<List<dynamic>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        final comments = snapshot.data ?? [];

        final children = [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Text(
              'Commentaires (${comments.length})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (snapshot.connectionState == ConnectionState.waiting)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (snapshot.hasError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Impossible de charger les commentaires.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            )
          else if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Aucun commentaire pour le moment.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            )
          else
            ...comments.map((comment) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(comment['username']?.toString() ?? 'Utilisateur'),
                subtitle: Text(comment['content']?.toString() ?? ''),
              );
            }),
        ];

        if (!widget.expand) {
          return Column(children: children);
        }

        return ListView(
          controller: widget.scrollController,
          children: children,
        );
      },
    );

    return Column(
      children: [
        if (widget.expand) Expanded(child: commentsView) else commentsView,
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ajouter un commentaire...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isSending ? null : _submit,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
