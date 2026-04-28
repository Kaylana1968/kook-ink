import 'package:flutter/material.dart';

class FavorisList extends StatelessWidget {
  const FavorisList({super.key});

  @override
  Widget build(BuildContext context) {
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
