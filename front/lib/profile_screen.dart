import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER : avatar + stats
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _stat('12', 'Posts'),
                        _stat('340', 'Followers'),
                        _stat('180', 'Following'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // BIO
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    'Recettes simples / Fait maison',
                    style: TextStyle(
                      color: Color.fromARGB(253, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // BOUTONS
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('Modifier le profil'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('Partager le profil'),
                    ),
                  ),
                ],
              ),
            ),

            // ONGLET ICONES
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Post',
                    style: TextStyle(
                      color: Color.fromARGB(253, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Recettes',
                    style: TextStyle(
                      color: Color.fromARGB(253, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Favoris',
                    style: TextStyle(
                      color: Color.fromARGB(253, 0, 0, 0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // GRILLE INSTAGRAM
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey.shade300,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label),
      ],
    );
  }
}
