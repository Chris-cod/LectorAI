import 'dart:ui';
import 'package:flutter/material.dart';
import 'camera_controller_service.dart';
import 'image_display_widget.dart';

/*
 * Autor: Ayham
 * Fakultät: TI
 * Matrikelnummer: 5188947
 * Fachsemester: 6
 * 
 * Die `CameraPage`-Klasse ist eine StatefulWidget, die eine Seite für die
 * Kamerainteraktionen bereitstellt. Sie verwaltet die Kamera, zeigt ein Overlay vor 
 * der Bildaufnahme und ermöglicht die Anzeige des aufgenommenen Bildes.
 */

class CameraPage extends StatefulWidget
{
  const CameraPage({super.key, required this.token, required this.dmodus});

  // Authentifizierungstoken für API-Anfragen.
  final String token;

  // Entwicklungsmodus-Flag, das angibt, ob die Anwendung im Entwicklungsmodus läuft.
  final bool dmodus;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
{
  // Verwaltung der Kamerainteraktionen.
  late CameraControllerService _cameraControllerService;
  // Zustandsvariable, die kontrolliert, ob ein Overlay vor dem Start angezeigt wird.
   bool _overlayBeforeStart = true;

  @override
  void initState()
  {
    super.initState();
    // Initialisiert den Kamera-Controller-Dienst.
    _cameraControllerService = CameraControllerService();
  }

  @override
  void dispose()
  {
    // Bereinigt den Kamera-Controller-Dienst beim Verlassen der Seite.
    _cameraControllerService.dispose();
    super.dispose();
  }

  // Bestätigungsfunktion für das Overlay, führt zur Bildaufnahme.
  void _confirmOverlay() 
  {
    setState(() 
    {
      _overlayBeforeStart = false; // Setzt das Overlay auf unsichtbar.
    });
    // Prüft die Bildaufnahme und navigiert zurück, wenn diese fehlschlägt.
    _checkCaptureAndNavigateBack(); 
  }
  
  // Erfasst Bilder und gibt zurück, ob die Erfassung erfolgreich war.
 Future<bool> _capturePictures() async 
 {
    try {
      await _cameraControllerService.capturePictures(context, setState);
      if (mounted) 
      {
        setState(() {});
      }
      // Prüft, ob Bilder erfolgreich erfasst wurden.
      return _cameraControllerService.imageBytes != null;
    } catch (e) 
    {
      return false; // Gibt false zurück, wenn ein Fehler auftritt.
    }
  }

  // Prüft, ob die Bildaufnahme erfolgreich war, und navigiert bei Misserfolg zurück.
  void _checkCaptureAndNavigateBack() async 
  {
  bool isCaptureSuccessful = await _capturePictures();
    if (!isCaptureSuccessful && mounted) 
    {
      // Zurück zur vorherigen Seite.
      Navigator.of(context).pop();  
    }
  }



   @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          // Prüft, ob ein Bild vorhanden ist.
          if (_cameraControllerService.imageBytes != null)
            ImageDisplayWidget(
              imageBytes: _cameraControllerService.imageBytes!,
              onRetake: () 
              {
                setState(() 
                {
                  // Setzt das Bild zurück, um eine erneute Aufnahme zu ermöglichen.
                  _cameraControllerService.resetImage();
                });
              },
              token: widget.token,
              test: widget.dmodus,
            ),
          // Zeigt ein Overlay, bevor die Bildaufnahme beginnt.
          if (_overlayBeforeStart)
            Positioned.fill(
            child: Container(
              color: Color.fromARGB(255, 255, 166, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Bitte stellen Sie sicher, dass das Foto ohne Verdeckungen, Schatten oder ähnliche Beeinträchtigungen aufgenommen wird.",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _confirmOverlay,
                    child: Text('Verstanden'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}