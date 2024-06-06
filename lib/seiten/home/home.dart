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
          // SafeArea sorgt dafür, dass der Inhalt innerhalb der sicheren Bereiche der Anzeige bleibt
          child: Column(
        // Ein Column-Widget wird verwendet, um Widgets vertikal anzuordnen
        mainAxisAlignment:
            MainAxisAlignment.center, // Zentriert die Elemente vertikal
        children: <Widget>[
          const Text(
            'LectorAI',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black, // Textfarbe
              fontSize: 66,
            ),
          ),
          const SizedBox(
              height: 45), // Ein Abstand zwischen dem Text und dem Bild
          Image.asset(
            'assets/Bilder/lectorAI_Logo.png', // Der Pfad zu dem Bild-Asset
            scale: 1.0, // Die Skalierung des Bildes
          ),
          const SizedBox(height: 95), // Ein weiterer Abstand
          Image.asset(
            'assets/Bilder/Logo_HSB_Hochschule_Bremen.png', // Der Pfad zu dem HSB Bild-Asset
            scale: 8.0, // Die Skalierung des HSB-Logos weiter verkleinert
          ),
        ],
      )),
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
