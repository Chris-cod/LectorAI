import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:ui';

// Klasse, die eine Seite zur Bildanzeige repräsentiert.
class ViewImagePage extends StatelessWidget 
{
  final Uint8List imageBytes;
  final VoidCallback? onReturn;

  const ViewImagePage({Key? key, required this.imageBytes, this.onReturn}) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      // Liegt Widgets übereinander.
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.memory(
              
              imageBytes, // Lädt das Bild direkt aus den übergebenen Bytes.
              fit: BoxFit.cover, // Skaliert das Bild, um den gesamten Bildschirm auszufüllen.
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          // Scharfe Bildmitte
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),
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
                if (onReturn != null) {
                  onReturn!();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}