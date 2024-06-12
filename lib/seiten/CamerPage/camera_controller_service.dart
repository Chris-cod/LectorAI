import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

class CameraControllerService {
  Uint8List? imageBytes; // Gespeichertes Bild in Byte-Array-Form

  // Nimmt Bilder auf und konvertiert sie in ein Byte-Array, speichert es in imageBytes
  Future<void> capturePictures(BuildContext context, Function setState) async {
    List<String> picturesPaths;
    try {
      // Versucht Bilder mit dem Dokumentenscanner-Paket zu bekommen
      picturesPaths = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted(context)) return; // Überprüft, ob das Widget noch montiert ist
      if (picturesPaths.isNotEmpty) {
        // Liest das erste Bild als Beispiel und konvertiert es in ein Byte-Array
        final file = File(picturesPaths.first);
        final bytes = await file.readAsBytes();
        setState(() {
          imageBytes = bytes; // Speichert das Byte-Array im Zustand
        });
      }
    } catch (e) {
      // Fehlerdialog anzeigen, wenn ein Fehler auftritt
      _showErrorDialog(context, e.toString());
    }
  }

  // Zeigt einen Fehlerdialog an
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fehler'), // Titel des Dialogs
        content: Text('Fehler: $errorMessage'), // Fehlernachricht
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Methode zum Freigeben von Ressourcen
  void dispose() {
    // Ressourcen freigeben, falls erforderlich
  }

  // Methode zum Zurücksetzen des Bildes
  void resetImage() {
    imageBytes = null;
  }

  // Überprüft, ob das Widget noch montiert ist
  bool mounted(BuildContext context) {
    return context.findRenderObject()?.attached ?? false;
  }
}