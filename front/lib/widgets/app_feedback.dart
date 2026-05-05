import 'package:flutter/material.dart';

final appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void showAppFeedback(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted && appScaffoldMessengerKey.currentState == null) return;

  final messenger = appScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
