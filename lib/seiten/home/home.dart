import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/Login/LoginPage.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  LoadingStartPage createState() => LoadingStartPage();
}

class LoadingStartPage extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold bietet das Grundgerüst für unser App-Layout
    return Scaffold(
      backgroundColor:
          const Color(0xFFB9B5C6), // Hintergrundfarbe geändert auf ein Hellgrau
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'LectorAI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        66, // Feste Schriftgröße, die auf verschiedenen Geräten gut aussieht
                  ),
                ),
                const SizedBox(height: 45),
                FractionallySizedBox(
                  widthFactor: 0.9, // 90% der Bildschirmbreite
                  child: Image.asset(
                    'assets/Bilder/lectorAI_Logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 95),
                FractionallySizedBox(
                  widthFactor: 0.5, // 50% der Bildschirmbreite
                  child: Image.asset(
                    'assets/Bilder/Logo_HSB_Hochschule_Bremen.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  startTime() async {
    var duration = Duration(seconds: 5); // Wartezeit von 5 Sekunden
    return Timer(duration,
        route); // Timer, der nach der Wartezeit die route Funktion aufruft
  }

  route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigation zur LoginPage
    );
  }
}
