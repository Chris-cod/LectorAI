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
        child: SingleChildScrollView( // Add SingleChildScrollView here
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'LectorAI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 66,
                ),
              ),
              const SizedBox(height: 45),
              Image.asset(
                'assets/Bilder/lectorAI_Logo.png',
                scale: 1.0,
              ),
              const SizedBox(height: 95),
              Image.asset(
                'assets/Bilder/Logo_HSB_Hochschule_Bremen.png',
                scale: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  startTime() async {
    var duration = Duration(seconds: 5);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}

