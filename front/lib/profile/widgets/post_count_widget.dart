import 'package:flutter/material.dart';
import 'stat_widget.dart';

class PostCountWidget extends StatelessWidget {
  final Future<List<dynamic>> postFuture;
  final Future<List<dynamic>> recipeFuture;

  const PostCountWidget({
    super.key,
    required this.postFuture,
    required this.recipeFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([postFuture, recipeFuture]),
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          List posts = snapshot.data![0];
          List recipes = snapshot.data![1];

          count = posts.length + recipes.length;
        }

        return StatWidget(
          value: count.toString(),
          label: 'Publications',
        );
      },
    );
  }
}
