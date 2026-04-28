import 'package:flutter/material.dart';

class PostQuestionScreen extends StatelessWidget {
  const PostQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const orangeKook = Color(0xFFFF8A00);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('Poser une question', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildField("Titre", "Titre", orangeKook),
            const SizedBox(height: 20),
            _buildField("Text", "Text", orangeKook, maxLines: 8),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Filtres", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _filterChip(orangeKook),
                _filterChip(orangeKook),
                _filterChip(orangeKook),
              ],
            ),
            Row(
              children: [
                _filterChip(orangeKook),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.grey)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeKook,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, Color color, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: color), borderRadius: BorderRadius.circular(8)),
            border: OutlineInputBorder(borderSide: BorderSide(color: color), borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 30,
      width: 70,
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}