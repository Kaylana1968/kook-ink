import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'forum_screen.dart';
import 'profile_screen.dart';
import 'mini_screen.dart';
import 'notification_screen.dart';
import 'message_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    MiniScreen(),
    ForumScreen(),
    ProfileScreen(),
    MessageScreen(),
    NotificationScreen(),
  ];

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(
            onItemSelected: _changePage,
          ),
          Expanded(child: _pages[_currentIndex]),
          Footer(
            currentIndex: _currentIndex,
            onItemSelected: _changePage,
          ),
        ],
      ),
    );
  }
}