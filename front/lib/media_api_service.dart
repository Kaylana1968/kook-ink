import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MediaApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "http://localhost:8000";

  static Uri image() => Uri.parse('$baseUrl/image');

  static Future<String> uploadImage(XFile file) async {
    final token = await AuthService.getToken();
    final request = http.MultipartRequest('POST', image());
    final bytes = await file.readAsBytes();

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: file.name,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur upload image: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final imageLink = data['image_link']?.toString();

    if (imageLink == null || imageLink.isEmpty) {
      throw Exception("L'upload n'a pas renvoye d'URL image");
    }

    return imageLink;
  }
}
