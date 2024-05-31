import 'dart:convert';

import 'package:azureai_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthenticationService {
  final String apiUrl = dotenv.env['USERS_API_ENDPOINT']!;

  Future<Map<String, String>> insertUser(String name, String password) async {
    const Map<String, String> defaultErrorMessage = {
      'error': 'Error inserting user. Please try again later',
    };

    try {
      User user = User(name: name, password: password);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return {
          'message': 'User inserted successfully',
        };
      } else if (response.statusCode == 409) {
        return {
          'error': 'This name already exists. Please try another one',
        };
      } else {
        return defaultErrorMessage;
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
    return defaultErrorMessage;
  }

  Future<http.Response> getUserByName(String name) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/name/$name'));
      return response;
    } catch (e) {
      print('Error de conexión: $e');
      throw Exception('Connection error. Please try again later');
    }
  }
}
