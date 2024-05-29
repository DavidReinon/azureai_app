import 'dart:convert';

import 'package:azureai_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthenticationService {
  final String apiUrl = dotenv.env['USERS_API_ENDPOINT']!;

  Future<Map<String, String>> insertUser(String name, String password) async {
    const Map<String, String> defaultErrorMessage = {
      'error': 'Error al insertar el usuario. Intentalo mas tarde',
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
          'message': 'Usuario insertado correctamente',
        };
      } else if (response.statusCode == 409) {
        return {
          'error': 'Este nombre ya existe. Intentalo con otro',
        };
      } else {
        return defaultErrorMessage;
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
    return defaultErrorMessage;
  }

  Future<bool> checkUserExists(String name) async {
    bool userExist = false;
    try {
      final response = await http.get(Uri.parse('$apiUrl/name/$name'));

      if (response.statusCode == 200) {
        userExist = true;
      } else if (response.statusCode != 404) {
        print('Error al verificar la existencia del usuario');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
    return userExist;
  }

  //TODO: ChechUserCredentials => Password
}
