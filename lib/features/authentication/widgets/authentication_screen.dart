import 'package:azureai_app/features/authentication/widgets/log_in_screen.dart';
import 'package:azureai_app/features/authentication/widgets/sign_up_screen.dart';
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
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            // Buttons widget
            Column(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(300, 30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => LogInScreen()),
                    );
                  },
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(300, 30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => SignUpScreen()),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(const Size(150, 30)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage()
                          ),
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
