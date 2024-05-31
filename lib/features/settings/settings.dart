import 'package:azureai_app/features/authentication/widgets/authentication_screen.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const AuthenticationScreen()),
            (Route<dynamic> route) => false,
          );
        },
        child: const Text('Log Out'),
      ),
    );
  }
}
