import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class CameraControllerService 
{
  CameraController? controller;
  Future<void>? initializeControllerFuture;
  Uint8List? imageBytes;

  // Initialisiert die Kamera und stellt sicher, dass die Kamera bereit ist
  Future<void> initCamera(BuildContext context) async 
  {
    try 
    {
      // Holt die verfügbare Kameraliste
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) 
      {
        // Initialisiert die Kamera mit der höchsten Auflösung und deaktiviert Audio
        controller = CameraController(cameras[0], ResolutionPreset.max, enableAudio: false);
        initializeControllerFuture = controller?.initialize();
        // Wartet auf die Initialisierung
        await initializeControllerFuture;
      }
    } catch (e) 
    {
      _showCameraErrorDialog(context, e); // Zeigt bei Fehlern einen Dialog an
    }
  }

  // Zeigt einen Fehlerdialog bei Kamerafehlern an
  void _showCameraErrorDialog(BuildContext context, dynamic e) 
  {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kamerafehler'),
        content: Text('Fehler beim Zugriff auf die Kamera: $e'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Nimmt ein Bild auf und aktualisiert den Zustand mit den Bilddaten
  void captureAndNavigate(BuildContext context, Function setState) async 
  {
    if (controller != null && controller!.value.isInitialized) 
    {
      try {
        // Macht ein Foto und liest die Bilddaten
        final image = await controller!.takePicture();
        final bytes = await image.readAsBytes();
        setState(() {
          imageBytes = bytes; // Setzt die Bilddaten
          controller?.pausePreview(); // Pausiert die Vorschau
        });
      } 
      catch (e) 
      {
        // Gibt einen Fehler bei der Aufnahme aus
        print('Fehler beim Aufnehmen des Bildes: $e');  
      }
    }
  }

  // Setzt das Bild zurück und setzt die Vorschau fort
  void resetImage() 
  {
    imageBytes = null;
    controller?.resumePreview();  // Setzt die Vorschau fort
  }

  // Räumt die Kameraressourcen auf
  void dispose() 
  {
    controller?.dispose();
  }
}
