import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_controller_service.dart';
import 'image_display_widget.dart';

class CameraPage extends StatefulWidget 
{
  const CameraPage({super.key, required this.token, required this.dmodus});

  final String token;
  final bool dmodus;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
{
  late CameraControllerService _cameraControllerService;
   bool _overlayBeforeStart = true; // Zustand, ob das Overlay angezeigt wird

  @override
  void initState() 
  {
    super.initState();
    // Initialisiert den Kamera-Controller-Dienst
    _cameraControllerService = CameraControllerService();
  }

  @override
  void dispose() 
  {
    // Entsorgt den Kamera-Controller-Dienst
    _cameraControllerService.dispose();
    super.dispose();
  }

  void _confirmOverlay() {
    setState(() {
      _overlayBeforeStart = false;  // Overlay ausblenden, wenn der Benutzer bestätigt
    });
    _capturePictures();  // Startet die Bilderfassung, nachdem das Overlay bestätigt wurde
  }

  void _capturePictures() async {
    await _cameraControllerService.capturePictures(context, setState);
    if (mounted) {
      setState(() {});
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_cameraControllerService.imageBytes != null)
            // Zeigt das aufgenommene Bild an
            ImageDisplayWidget(
              imageBytes: _cameraControllerService.imageBytes!,
              onRetake: () {
                setState(() {
                  _cameraControllerService.resetImage();
                });
              },
              token: widget.token,
              test: widget.dmodus,
            ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_overlayBeforeStart)
            Positioned.fill(
              child: Container(
                color: Color.fromARGB(137, 223, 20, 20),
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