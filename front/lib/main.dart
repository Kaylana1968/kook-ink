import 'package:flutter/material.dart';
import 'package:front/auth_service.dart';
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
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          surface: Colors.white,
        ),
      ),
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
  Widget _currentPage = const HomeScreen();
  bool _isLoggedIn = false;
  bool _isLoading = true; // Flag to handle the initial check

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthService().getToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _isLoading = false; // Check is done
      });
    }
  }

  void _onLogin() {
    setState(() {
      _isLoggedIn = true;
      _currentPage = const ProfileScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Handle the loading state simply at the top
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    // Return a clean Scaffold without FutureBuilder nesting
    return Scaffold(
      body: Column(
        children: [
          Header(onItemSelected: (p) => setState(() => _currentPage = p)),
          Expanded(child: _currentPage),
          Footer(
            currentPage: _currentPage,
            onItemSelected: (selectedPage) {
              if (selectedPage is ProfileScreen && !_isLoggedIn) {
                setState(() => _currentPage = LoginForm(onLogin: _onLogin));
              } else {
                setState(() => _currentPage = selectedPage);
              }
            },
          ),
        ],
      ),
    );
  }
}
