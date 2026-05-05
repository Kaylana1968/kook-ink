import 'package:flutter/material.dart';
import 'package:front/forum/forum_screen.dart';
import 'package:front/layout.dart';
import 'package:front/recipe/recipe_screen.dart';
import 'package:front/forum/widgets/forum_detail_screen.dart';
import 'package:front/forum/widgets/post_question_screen.dart';
import 'package:go_router/go_router.dart';
import 'home/home_screen.dart';
import 'home/post_detail_screen.dart';
import 'home/recipe_detail_screen.dart';
import 'authentification/login_screen.dart';
import 'profile/profile_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/app_feedback.dart';

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
                path: '/detail/post/:postId',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['postId']!);
                  return PostDetailScreen(postId: id);
                },
              ),
              GoRoute(
                path: '/detail/recipe/:recipeId',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['recipeId']!);
                  return RecipeDetailScreen(recipeId: id);
                },
              ),
              GoRoute(
                path: '/forum',
                builder: (context, state) => const ForumScreen(),
              ),
              GoRoute(
                path: '/forum/post',
                builder: (context, state) => const PostQuestionScreen(),
              ),
              GoRoute(
                path: '/forum/:postId',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['postId']!);
                  final extra = state.extra;
                  final title = extra is Map
                      ? extra['title']?.toString() ?? ''
                      : (extra as String?) ?? '';
                  final author =
                      extra is Map ? extra['author']?.toString() : null;
                  final userId = extra is Map ? extra['user_id'] : null;

                  return ForumDetailScreen(
                    postId: id,
                    title: title,
                    initialAuthor: author,
                    initialAuthorId: userId,
                  );
                },
              ),
            ])
      ],
    );

    return MaterialApp.router(
      scaffoldMessengerKey: appScaffoldMessengerKey,
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
