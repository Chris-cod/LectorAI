import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

/*
 * Autor: Ayham
 * Fakultät: TI
 * Matrikelnummer: 5188947
 * Fachsemester: 6
 * 
 * Diese Klasse enthält Methoden zum Erfassen von Bildern mit einem Dokumentenscanner,
 * zum Anzeigen von Fehlerdialogen, zum Zurücksetzen von Bildern und zur Überprüfung,
 * ob der Kontext noch im Widget-Baum vorhanden ist.
 */

class CameraControllerService 
{
  // Gespeichertes Bild in Byte-Array-Form
  Uint8List? imageBytes; 

  // Nimmt Bilder auf und konvertiert sie in ein Byte-Array, speichert es in imageBytes
  Future<void> capturePictures(BuildContext context, Function setState) async 
  {
    List<String> picturesPaths;
    try 
    {
      // Versucht Bilder mit dem Dokumentenscanner-Paket zu bekommen
      picturesPaths = await CunningDocumentScanner.getPictures() ?? [];
      // Überprüft, ob das Widget noch montiert ist
      if (!mounted(context)) return;
      if (picturesPaths.isNotEmpty) 
      {
        // Liest das erste Bild als Beispiel und konvertiert es in ein Byte-Array
        final file = File(picturesPaths.first);
        final bytes = await file.readAsBytes();
        setState(() 
        {
          // Speichert das Byte-Array im Zustand
          imageBytes = bytes; 
        });
      }
    } catch (e) 
    {
      // Fehlerdialog anzeigen, wenn ein Fehler auftritt
      _showErrorDialog(context, e.toString());
    }
  }

  // Zeigt einen Fehlerdialog an
  void _showErrorDialog(BuildContext context, String errorMessage) 
  {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fehler'),
        content: Text('Fehler: $errorMessage'),
        actions: <Widget>[
          TextButton(
            onPressed: ()
            {
              // Zurück zur vorherigen Seite.
              Navigator.of(context).pop();
              // Zurück zur vorherigen Seite.
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Methode zum Freigeben von Ressourcen
  void dispose() 
  {
    // Ressourcen freigeben, falls erforderlich
  }

  // Methode zum Zurücksetzen des Bildes
  void resetImage() 
  {
    imageBytes = null;
  }

  // Überprüft, ob das Widget noch montiert ist
  bool mounted(BuildContext context) 
  {
    return context.findRenderObject()?.attached ?? false;
  }
}