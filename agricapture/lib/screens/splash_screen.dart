import 'package:agricapture/screens/farmer_form_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                   FarmerFormScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo or any introductory content
            Image.asset('images/logo.png', width: screenSize.width / 1.5),
            const SizedBox(height: 20),
            Text('Agri Capture',
                style: GoogleFonts.lato(
                    textStyle:
                        const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
