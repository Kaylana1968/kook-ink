import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

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
  bool isLoggedIn = false;

  void _changePage(Widget selectedPage) {
    setState(() {
      page = selectedPage;
    });
  }

  void _onLogin(bool state) {
    setState(() {
      isLoggedIn = state;
    });

    print(state);
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
            onItemSelected: (selectedPage) {
              if (selectedPage is ProfileScreen && !isLoggedIn) {
                _changePage(
                  LoginForm(
                    onLogin: _onLogin,
                  ),
                );
              } else {
                _changePage(selectedPage);
              }
            },
          ),
        ],
      ),
    );
  }
}
