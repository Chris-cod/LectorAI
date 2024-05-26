import 'dart:typed_data';
import 'package:flutter/material.dart';

// Klasse, die eine Seite zur Bildanzeige repräsentiert.
class ViewImagePage extends StatelessWidget {
  final Uint8List imageBytes;

  const ViewImagePage({Key? key, required this.imageBytes}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      // Liegt Widgets übereinander.
      body: Stack(
        children: [
          Center(
            // Zeigt das Bild direkt aus dem Speicher an.
            child: Image.memory(
              imageBytes, // Lädt das Bild direkt aus den übergebenen Bytes.
              fit: BoxFit.cover, // Skaliert das Bild, um den gesamten Bildschirm auszufüllen.
              width: double.infinity, // Setzt die Breite auf unendlich für volle Breite.
              height: double.infinity // Setzt die Höhe auf unendlich für volle Höhe.
            ),
          ),
          // Platziert ein IconButton oben links auf dem Bildschirm.
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () 
              {
                Navigator.of(context).pop(); // Zurück zur vorherigen Seite.
              },
            ),
          ),
        ],
      ),
    );
  }
}