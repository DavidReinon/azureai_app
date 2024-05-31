import 'dart:convert';

import 'package:azureai_app/features/home_page/widgets/my_home_page.dart';
import 'package:azureai_app/models/user.dart';
import 'package:flutter/material.dart';
import '../services/authentication_service.dart';

final AuthenticationService authService = AuthenticationService();

class LogInScreen extends StatelessWidget {
  LogInScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool correctPassword(String password) {
    return password == _passwordController.text;
  }

  void onPressed(BuildContext context) async {
    try {
      final response = await authService.getUserByName(_nameController.text);
      if (response.statusCode == 404) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User does not exist. Please sign up first'),
          ),
        );
        return;
      }

      User user = User.fromMap(jsonDecode(response.body));
      if (!correctPassword(user.getPassword!)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect password. Please try again'),
          ),
        );
        return;
      }

      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error de conexión: $e');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error. Please try again later'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Log In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Log in to your account to acces to OCR!',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 30.0),
            Image.asset(
              'assets/picture_avatar_green.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 15.0),
            Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _nameController,
                ),
                const SizedBox(height: 30.0),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(350, 30)),
                  ),
                  onPressed: () {
                    onPressed(context);
                  },
                  child: const Text('Log In', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
