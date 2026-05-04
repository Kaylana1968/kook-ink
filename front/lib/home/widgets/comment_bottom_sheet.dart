import 'package:flutter/material.dart';
import 'package:front/home/services/detail_api_service.dart';
import 'package:front/home/widgets/comment_section.dart';

Future<bool> showCommentsBottomSheet({
  required BuildContext context,
  required String type,
  required int itemId,
}) {
  final isRecipe = type == 'recipe';
  var hasNewComment = false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.35,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: CommentSection(
                  expand: true,
                  scrollController: scrollController,
                  onCommentCreated: () => hasNewComment = true,
                  loadComments: () => isRecipe
                      ? DetailApiService.fetchRecipeComments(itemId)
                      : DetailApiService.fetchPostComments(itemId),
                  onSubmit: (content) => isRecipe
                      ? DetailApiService.createRecipeComment(itemId, content)
                      : DetailApiService.createPostComment(itemId, content),
                ),
              ),
            ],
          );
        },
      );
    },
  ).then((_) => hasNewComment);
}
