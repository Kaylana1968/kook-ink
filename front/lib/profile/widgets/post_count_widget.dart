import 'package:flutter/material.dart';
import 'stat_widget.dart';

class PostCountWidget extends StatelessWidget {
  final Future<List<dynamic>> postFuture;

  const PostCountWidget({
    super.key,
    required this.postFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: postFuture,
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          count = snapshot.data!.length;
        }

        return StatWidget(
          value: count.toString(),
          label: 'Posts',
        );
      },
    );
  }
}
