import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget page = const HomeScreen();

  void _changePage(Widget selectedPage) {
    setState(() {
      page = selectedPage;
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
          Expanded(child: page),
          Footer(
            currentPage: page,
            onItemSelected: _changePage,
          ),
        ],
      ),
    );
  }
}
