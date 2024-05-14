import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/Login/LoginPage.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold bietet das Grundgerüst für unser App-Layout
    return Scaffold(
      backgroundColor: const Color(
          0xFF0077B6), //Hier wird der Hintergrund gesetzt (Honolulu Blue)
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
              color: Colors.black, //Textfarbe
              fontSize: 66,
            ),
          ),
          const SizedBox(
              height: 45), // Ein Abstand zwischen dem Text und dem Bild
          Image.asset(
            'assets/Bilder/lectorAI_Logo.png', //Der Pfad zu dem Bild-Asset
            scale: 1.0, //Die Skalierung des Bildes
          ),
          const SizedBox(height: 95), //Ein weiterer Abstand
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (Context) => const LoginPage()),
              );
              // Die Aktion, die passiert, wenn der Button gedrückt wird.
              // Hier soll man die Navigation zum Login einfügen.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF48CAE4), // Die Hintergrundfarbe des Buttons
              foregroundColor:
                  Colors.black, //Die Farbe des Textes und des Icons im Button
              textStyle:
                  const TextStyle(fontSize: 35), // Die Textgröße im Button
              padding: const EdgeInsets.symmetric(
                  horizontal: 35, vertical: 1), // Der Innenabstand des Buttons
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0), // Abgerundete Ecken
                side: const BorderSide(color: Colors.black), //Schwarz Umrandung
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, //Button-Inhalt so klein wie möglich halten
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, //Verteilt den Raum gleich zwischen den Children
              children: <Widget>[
                const Text(
                  '   Starten',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(width: 15), //Icon nach dem Text
                Image.asset(
                  'assets/Bilder/Icon_play.png',
                  width: 100,
                  height: 75,
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}
