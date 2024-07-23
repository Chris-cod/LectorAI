import 'package:flutter/material.dart';

class InitialOverlay extends StatelessWidget {
  final VoidCallback onEintragenPressed; // Callback für den Eintragen-Button
  final VoidCallback onAuswaehlenPressed; // Callback für den Auswählen-Button

  // Konstruktor der Klasse InitialOverlay, der die Callback-Funktionen initialisiert
  InitialOverlay({
    required this.onEintragenPressed,
    required this.onAuswaehlenPressed,
  });

  @override
  //erstellt das UI für das Overlay
  Widget build(BuildContext context) {
    // Erzeugt das Overlay-Center-Widget
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
         // Dekoration des Containers, einschließlich Hintergrundfarbe und abgerundeter Ecken
        decoration: BoxDecoration(
          color: Color(0xff3d7c88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bitte wählen Sie eine Option:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16), // Abstand zwischen Text und erstem Button
            ElevatedButton(
              onPressed: onAuswaehlenPressed,
              child: Text('Auswählen'),
            ),
            SizedBox(height: 8), // Abstand zwischen den beiden Buttons
            //ElevatedButton: Zwei Schaltflächen, die die Callback-Funktionen ausführen, wenn sie gedrückt werden.
            ElevatedButton(
              onPressed: onEintragenPressed,
              child: Text('Eintragen'),
            ),
          ],
        ),
      ),
    );
  }
}
