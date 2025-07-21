import 'package:flutter/material.dart';
import 'package:shop_app/login/login_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 196, 152, 136),
      body: Center(
        child: Text(
          'Shop Khata',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
