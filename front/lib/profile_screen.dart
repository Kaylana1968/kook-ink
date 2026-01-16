import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<dynamic>> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = fetchRecipes();
  }

  Future<List<dynamic>> fetchRecipes() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/recipe'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['recipes'];
    } else {
      throw Exception('Erreur serveur');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _recipeFuture = fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Stat(value: '12', label: 'Posts'),
                          _Stat(value: '340', label: 'Followers'),
                          _Stat(value: '180', label: 'Following'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BIO
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recettes simples / Fait maison',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              // BOUTONS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Modifier le profil'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Partager le profil'),
                      ),
                    ),
                  ],
                ),
              ),

              // TABS
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: 'Post'),
                  Tab(text: 'Recettes'),
                  Tab(text: 'Favoris'),
                ],
              ),

              // TAB CONTENT
              SizedBox(
                height: 600,
                child: TabBarView(
                  children: [
                    _postsGrid(),
                    _recettesGrid3(),
                    _favorisList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ONGLET POSTS
  Widget _postsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (_, __) => Container(color: Colors.grey.shade300),
    );
  }

  // ONGLET RECETTES
  Widget _recettesGrid3() {
    return FutureBuilder<List<dynamic>>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: TextButton(
              onPressed: _refresh,
              child: const Text("Erreur - Réessayer"),
            ),
          );
        }

        final recipes = snapshot.data!;
        if (recipes.isEmpty) {
          return const Center(child: Text("Aucune recette"));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: recipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final recipe = recipes[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      recipe['image_link'] ?? 'https://via.placeholder.com/300',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'] ?? 'Sans titre',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _infoChip(Icons.timer_outlined,
                            "${recipe['preparation_time'] ?? 0} min"),
                        _infoChip(Icons.local_fire_department_outlined,
                            "${recipe['baking_time'] ?? 0} min"),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ONGLET FAVORIS
  Widget _favorisList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: Icon(Icons.favorite, color: Colors.red),
          title: Text('Favori'),
        );
      },
    );
  }
}

// ICONS STYLE
class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
