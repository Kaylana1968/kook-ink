import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/recipe/models/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // part of the http package
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/recipe/services/recipe_api_service.dart';

void main() {
  setUpAll(() async {
    // Provide a minimal .env so dotenv doesn't crash
    dotenv.testLoad(fileInput: 'BASE_URL=http://localhost:8000');
  });

  group('RecipeApiService.createRecipe', () {
    final body = {'title': 'Pasta'};

    test('completes without throwing on 201', () async {
      final mockClient =
          MockClient((_) async => http.Response(jsonEncode({'id': 1}), 201));

      await expectLater(
        RecipeApiService.createRecipe(body, client: mockClient, token: "fake-token"),
        completes,
      );
    });

    test('throws ApiException on error', () async {
      final mockClient = MockClient((_) async =>
          http.Response(jsonEncode({'error': 'bad request'}), 400));

      await expectLater(
        RecipeApiService.createRecipe(body, client: mockClient, token: "fake-token"),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400)),
      );
    });

    test('propagates network exception', () async {
      final mockClient =
          MockClient((_) async => throw Exception('No internet'));

      await expectLater(
        RecipeApiService.createRecipe(body, client: mockClient, token: "fake-token"),
        throwsException,
      );
    });
  });
}
