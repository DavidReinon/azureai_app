import 'package:azureai_app/features/authentication/services/authentication_service.dart';
import 'package:flutter/material.dart';

final AuthenticationService authService = AuthenticationService();

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isPasswordMatch() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    return password == confirmPassword;
  }

  void onPressed(BuildContext context) async {
    if (!isPasswordMatch()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    final Map<String, String> response = await authService.insertUser(
        _nameController.text, _passwordController.text);

    if (!context.mounted) return;
    if (response['message'] != null) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['error']!),
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
              'Sign Up',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Crate new account and get started with OCR!',
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
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  controller: _confirmPasswordController,
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
                  child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
