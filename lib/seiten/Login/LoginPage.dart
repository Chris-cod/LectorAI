import 'package:flutter/material.dart'; // Importiert das Material Design Paket für Flutter.
import 'package:lectorai_frontend/models/lehrer.dart'; // Importiert das Lehrer-Modell.
import 'package:lectorai_frontend/seiten/HomePage/home_page.dart'; // Importiert die HomePage.
import 'package:lectorai_frontend/services/repository.dart'; // Importiert das Repository für Datenoperationen.
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importiert das dotenv Paket für das Laden von Umgebungsvariablen.
import 'package:lectorai_frontend/seiten/Settings/settings_page.dart'; // Importiert die Einstellungsseite.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Konstruktor für die LoginPage Klasse.

  @override
  _LoginPageState createState() =>
      _LoginPageState(); // Erstellt den Zustand der LoginPage.
}

class _LoginPageState extends State<LoginPage> {
  Lehrer lehrer = Lehrer(); // Instanz der Lehrer-Klasse.
  bool _isSecret = true; // Zustand zum Verbergen oder Anzeigen des Passworts.
  bool isDemoMode = false; // Zustand für den Demo-Modus.

  final TextEditingController _usernameController =
      TextEditingController(); // Controller für den Benutzernamen.
  final TextEditingController _passwordController =
      TextEditingController(); // Controller für das Passwort.
  final Repository repository =
      Repository(); // Instanz des Repositorys für Datenoperationen.

  @override
  void initState() {
    super.initState(); // Initialisiert den Zustand der Seite.
  }

  void toggleDemoMode(bool value) {
    setState(() {
      isDemoMode = value; // Setzt den Demo-Modus Zustand.
      if (isDemoMode) {
        // Setzt die Felder auf Demo-Daten, wenn der Demo-Modus aktiviert ist.
        _usernameController.text =
            dotenv.get('DEMO_USERNAME', fallback: 'defaultUser');
        _passwordController.text =
            dotenv.get('DEMO_PASSWORD', fallback: 'defaultPassword');
      } else {
        // Leert die Felder, wenn der Demo-Modus deaktiviert wird.
        _usernameController.clear();
        _passwordController.clear();
      }
    });
  }

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
    if (isDemoMode) {
      lehrer =
          await repository.loginFromLocalJson(username, password); // Demo-Login
    } else {
      lehrer = await repository.login(username, password); // Normaler Login
    }

    if (lehrer.isloggedin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
              lehrer: lehrer,
              demoModus:
                  isDemoMode), // Übergibt den Lehrer und den Demo-Modus an die HomePage.
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anmeldung fehlgeschlagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              // Ermöglicht das Scrollen, falls der Bildschirm zu klein ist.
              padding: const EdgeInsets.symmetric(
                  horizontal: 20), // Padding für die Ränder.
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor:
                        0.6, // Setzt die Breite des Logos auf 60% der Bildschirmbreite.
                    child: Image.asset(
                      'assets/Bilder/lectorAI_Logo.png',
                      fit: BoxFit
                          .contain, // Passt das Bild innerhalb der Box an, behält das Seitenverhältnis bei.
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInputField(
                    prefixImage: 'assets/Bilder/User.png',
                    hintText: 'E-Mail oder Benutzername',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                    ),
                    child: const Text("ANMELDEN",
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text(
                      'Demo-Modus',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: Checkbox(
                      value: isDemoMode,
                      onChanged: (bool? value) {
                        toggleDemoMode(
                            value ?? false); // Schaltet den Demo-Modus um.
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 36.0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SettingsPage(loggedIn: false)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String prefixImage,
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(prefixImage), // Lädt das Bild für das Eingabefeld.
        ),
        hintText: hintText, // Setzt den Platzhaltertext für das Eingabefeld.
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              25.0), // Abgerundete Ecken für das Eingabefeld.
          borderSide: BorderSide
              .none, // Entfernt die äußere Umrandung des Eingabefelds.
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isSecret, // Steuert die Sichtbarkeit des Passworts.
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
              'assets/Bilder/Lock.png'), // Bild für das Passwortfeld.
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isSecret
                ? Icons.visibility_off
                : Icons
                    .visibility, // Wechselt das Icon basierend auf dem Zustand der Sichtbarkeit.
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _isSecret =
                  !_isSecret; // Umschalten der Sichtbarkeit des Passworts.
            });
          },
        ),
        hintText: 'Kennwort', // Platzhaltertext für das Passwortfeld.
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              25.0), // Abgerundete Ecken für das Eingabefeld.
          borderSide: BorderSide
              .none, // Entfernt die äußere Umrandung des Eingabefelds.
        ),
      ),
    );
  }
}
