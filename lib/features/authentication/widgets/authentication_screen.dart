import 'package:azureai_app/features/home_page/widgets/my_home_page.dart';
import 'package:flutter/material.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo widget
            Flexible(
              child: Image.asset(
                'assets/OCR logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            // Buttons widget
            Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(150, 30)),
                  ),
                  onPressed: () {
                    // Handle login button presss
                  },
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(150, 30)),
                  ),
                  onPressed: () {
                    // Handle register button press
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(150, 30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()),
                    );
                  },
                  child: const Text('Enter as Guest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
