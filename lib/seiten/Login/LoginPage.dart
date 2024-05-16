import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert'; // Für das Konvertieren von JSON
import 'package:flutter/services.dart'
    show rootBundle; // Für den Zugriff auf die Asset-Ressourcen
import 'package:lectorai_frontend/models/lehrer.dart';
import 'package:lectorai_frontend/seiten/home_page.dart';
import 'package:lectorai_frontend/services/repository.dart'; // Import für die HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Lehrer lehrer = Lehrer(); // Instanz der Lehrer-Klasse
  bool _isSecret = true; // Zustand zum Verbergen oder Anzeigen des Passworts
  final TextEditingController _usernameController =
      TextEditingController(); // Controller für Benutzername
  final TextEditingController _passwordController =
      TextEditingController(); // Controller für Passwort
  final Repository repository = Repository();

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.length < 6 || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Benutzername muss mindestens 6 Zeichen und Passwort mindestens 8 Zeichen haben')),
      );
      return;
    }

    lehrer = await repository.login(username, password);
    if (lehrer.isloggedin) 
    {
      //Navigator.of(context)
      //    .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage(lehrer: lehrer), // Übergibt den Benutzernamen
      ));
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anmeldung fehlgeschlagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0077B6), // Setzt die Hintergrundfarbe der Login-Seite
      body: Stack(
        children: [
          Positioned(
            left: 23,
            top: 75, // Position des Zurück-Buttons
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Navigiert zurück zur HomePage
              },
              child: Image.asset(
                'assets/Bilder/_.png', // Das Bild als Zurück-Button
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), // Platz für den Zurück-Button
                  const Text(
                    "Willkommen Zurück",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors
                            .black), // Setzt Stil für den Text "Willkommen Zurück"
                  ),
                  const SizedBox(
                      height: 30), // Vertikaler Abstand zwischen den Elementen
                  _buildInputField(
                    prefixImage: 'assets/Bilder/User.png',
                    hintText:
                        'E-Mail oder Benutzer Name', // Textfeld für Benutzernamen
                    controller:
                        _usernameController, // Benutzt den Controller für den Benutzernamen
                  ),
                  const SizedBox(
                      height:
                          20), // Vertikaler Abstand zwischen den Eingabefeldern
                  _buildPasswordField(),
                  const SizedBox(
                      height: 30), // Vertikaler Abstand vor dem Anmeldebutton
                  ElevatedButton(
                    onPressed: _login,
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF48CAE4), // Setzt die Hintergrundfarbe des Buttons
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 10), // Padding für den Button
                    ),
                    child: const Text("ANMELDEN",
                        style: TextStyle(
                            color: Colors.black)), // Textinhalt des Buttons
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      {required String prefixImage,
      required String hintText,
      required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(prefixImage), // Lädt das Bild für das Eingabefeld
        ),
        hintText: hintText, // Setzt den Platzhaltertext für das Eingabefeld
        filled: true,
        fillColor: const Color(
            0xFFADE8F4), // Setzt die Hintergrundfarbe des Eingabefelds
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              25.0), // Abgerundete Ecken für das Eingabefeld
          borderSide:
              BorderSide.none, // Entfernt die äußere Umrandung des Eingabefelds
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isSecret, // Steuert die Sichtbarkeit des Passworts
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
              'assets/Bilder/Lock.png'), // Bild für das Passwortfeld
        ),
        suffixIcon: IconButton(
          icon: Icon(
            // Wechselt das Icon basierend auf dem Zustand der Sichtbarkeit
            _isSecret ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isSecret =
                  !_isSecret; // Umschalten der Sichtbarkeit des Passworts
            });
          },
        ),
        hintText: 'Kennwort', // Platzhaltertext für das Passwortfeld
        filled: true,
        fillColor: const Color(0xFFADE8F4), // Hintergrundfarbe des Eingabefelds
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              25.0), // Abgerundete Ecken für das Eingabefeld
          borderSide:
              BorderSide.none, // Entfernt die äußere Umrandung des Eingabefelds
        ),
      ),
    );
  }
}
