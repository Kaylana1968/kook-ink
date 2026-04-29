import 'package:flutter/material.dart';
import 'package:front/forum_screen.dart';
import 'package:front/layout.dart';
import 'package:front/message_screen.dart';
import 'package:front/mini_screen.dart';
import 'package:front/notification_screen.dart';
import 'package:front/recipe/recipe_screen.dart';
import 'package:front/search_screen.dart';
import 'package:front/forum_detail_screen.dart';
import 'package:front/post_question_screen.dart';
import 'package:go_router/go_router.dart';
import 'home/home_screen.dart';
import 'login_screen.dart';
import 'profile/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
            builder: (context, state, child) {
              return Layout(child: child);
            },
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginForm(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
              GoRoute(
                path: '/profile/:userId',
                builder: (context, state) {
                  final id = state.pathParameters['userId'];

                  return ProfileScreen(userId: int.parse(id!));
                },
              ),
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
              GoRoute(
                path: '/recipe',
                builder: (context, state) => const RecipeScreen(),
              ),
              GoRoute(
                path: '/recipe/:recipeId',
                builder: (context, state) {
                  final id = state.pathParameters['recipeId'];

                  return RecipeScreen(recipeId: int.parse(id!));
                },
              ),
              GoRoute(
                path: '/forum',
                builder: (context, state) => const ForumScreen(),
              ),
              GoRoute(
                path: '/minis',
                builder: (context, state) => const MiniScreen(),
              ),
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationScreen(),
              ),
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessageScreen(),
              ),
              GoRoute(
                path: '/forum/post',
                builder: (context, state) => const PostQuestionScreen(),
              ),
              GoRoute(
                path: '/forum/:postId',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['postId']!);
                  final title = state.extra as String? ?? '';
                  return ForumDetailScreen(postId: id, title: title);
                },
              ),
            ])
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          surface: Colors.white,
        ),
      ),
    );
  }
}