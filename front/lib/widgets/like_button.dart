import 'package:flutter/material.dart';
import 'package:front/services/like_api_service.dart';

class LikeButton extends StatefulWidget {
  final String type;
  final int itemId;
  final bool compact;
  final int? initialCount;

  const LikeButton({
    super.key,
    required this.type,
    required this.itemId,
    this.compact = false,
    this.initialCount,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool liked = false;
  bool loading = false;
  int count = 0;

  @override
  void initState() {
    super.initState();
    count = widget.initialCount ?? 0;
    _loadLike();
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.type != widget.type || oldWidget.itemId != widget.itemId) {
      _loadLike();
    }
  }

  Future<void> _loadLike() async {
    final data = await LikeApiService.fetchStatus(widget.type, widget.itemId);

    if (!mounted) return;

    setState(() {
      liked = data["liked"] == true;
      count = data["count"] is int ? data["count"] as int : 0;
    });
  }

  Future<void> _toggleLike() async {
    if (loading) return;

    setState(() {
      loading = true;
    });

    try {
      final data = liked
          ? await LikeApiService.unlike(widget.type, widget.itemId)
          : await LikeApiService.like(widget.type, widget.itemId);

      if (!mounted) return;

      setState(() {
        liked = data["liked"] == true;
        count = data["count"] is int ? data["count"] as int : 0;
        if (count < 0) count = 0;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossible de modifier le like : $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = liked ? Icons.favorite : Icons.favorite_border;
    final color = liked ? Colors.red : Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: loading ? null : _toggleLike,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 4 : 8,
          vertical: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: widget.compact ? 18 : 24),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: widget.compact ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
