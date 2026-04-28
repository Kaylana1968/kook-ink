import 'package:flutter/material.dart';
import 'package:front/auth_service.dart';
import 'header.dart';
import 'footer.dart';
import 'home_screen.dart';
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
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          surface: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static final ValueNotifier<int?> profileUserId = ValueNotifier<int?>(null);

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  static void openUserProfile(int userId) {
    profileUserId.value = userId;
  }

  static void openMyProfile() {
    profileUserId.value = null;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _currentPage = const HomeScreen();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool _isProfilePage = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();

    MyHomePage.profileUserId.addListener(_openProfileFromNotifier);
  }

  @override
  void dispose() {
    MyHomePage.profileUserId.removeListener(_openProfileFromNotifier);
    super.dispose();
  }

  void _openProfileFromNotifier() {
    final userId = MyHomePage.profileUserId.value;

    setState(() {
      _currentPage = ProfileScreen(userId: userId);
      _isProfilePage = true;
    });
  }

  Future<void> _checkAuth() async {
    final token = await AuthService().getToken();

    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  void _onLogin() {
    setState(() {
      _isLoggedIn = true;
      MyHomePage.openMyProfile();
      _currentPage = const ProfileScreen();
      _isProfilePage = true;
    });
  }

  void _selectPage(Widget selectedPage) {
    if (selectedPage is ProfileScreen && !_isLoggedIn) {
      setState(() {
        _currentPage = LoginForm(onLogin: _onLogin);
        _isProfilePage = false;
      });
      return;
    }

    if (selectedPage is ProfileScreen) {
      MyHomePage.openMyProfile();

      setState(() {
        _currentPage = const ProfileScreen();
        _isProfilePage = true;
      });
      return;
    }

    setState(() {
      _currentPage = selectedPage;
      _isProfilePage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Header(onItemSelected: _selectPage),
          Expanded(child: _currentPage),
          Footer(
            currentPage: _isProfilePage ? const ProfileScreen() : _currentPage,
            onItemSelected: _selectPage,
          ),
        ],
      ),
    );
  }
}
