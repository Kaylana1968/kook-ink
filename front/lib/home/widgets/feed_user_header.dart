import 'package:flutter/material.dart';
import 'package:front/profile/services/profile_api_service.dart';
import 'package:go_router/go_router.dart';

class FeedUserHeader extends StatelessWidget {
  final String username;
  final dynamic userId;

  const FeedUserHeader({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: userId == null ? null : () => _openProfile(context),
      mouseCursor: userId == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProfile(BuildContext context) async {
    final targetUserId = int.tryParse(userId.toString());

    if (targetUserId == null) {
      context.go("/profile/$userId");
      return;
    }

    try {
      final myProfile = await ProfileApiService.fetchMyProfile();
      final myUserId = int.tryParse(myProfile["id"]?.toString() ?? "");

      if (!context.mounted) return;

      context.go(
        myUserId == targetUserId ? "/profile" : "/profile/$targetUserId",
      );
    } catch (_) {
      if (!context.mounted) return;

      context.go("/profile/$targetUserId");
    }
  }
}
