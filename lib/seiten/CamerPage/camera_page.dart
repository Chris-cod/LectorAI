import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_controller_service.dart';
import 'image_display_widget.dart';

class CameraPage extends StatefulWidget 
{
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
{
  late CameraControllerService _cameraControllerService;

  @override
  void initState() 
  {
    super.initState();
    // Initialisiert den Kamera-Controller-Dienst
    _cameraControllerService = CameraControllerService();
    _initializeCamera();
  }

  // Initialisiert die Kamera 
  void _initializeCamera() async 
  {
    await _cameraControllerService.initCamera(context);
    if (mounted) 
    {
      // Aktualisiert den Zustand, nachdem die Kamera initialisiert wurde
      setState(() {});
    }
  }

  @override
  void dispose() 
  {
    // Entsorgt den Kamera-Controller-Dienst
    _cameraControllerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      body: Stack(
        children: [
          // Zeigt die Kamera-Vorschau, wenn der Controller verfügbar ist und kein Bild aufgenommen wurde
          if (_cameraControllerService.controller != null && _cameraControllerService.imageBytes == null)
            FutureBuilder<void>(
              future: _cameraControllerService.initializeControllerFuture,
              builder: (context, snapshot) 
              {
                if (snapshot.connectionState == ConnectionState.done) 
                {
                  // Kamera-Vorschau anzeigen, wenn der Controller initialisiert ist
                  return SizedBox.expand(child: CameraPreview(_cameraControllerService.controller!));
                } 
                else 
                {
                  // Zeigt einen Lade-Indikator, während der Controller initialisiert wird
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          // Zeigt den Auslöser-Button, wenn kein Bild aufgenommen wurde
          if (_cameraControllerService.imageBytes == null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FloatingActionButton(
                  child: const Icon(Icons.camera),
                  // Nimmt ein Bild auf und navigiert zur Bildanzeige
                  onPressed: () => _cameraControllerService.captureAndNavigate(context, setState),
                ),
              ),
            ),
          // Zeigt das aufgenommene Bild und die Option, ein neues Bild aufzunehmen
          if (_cameraControllerService.imageBytes != null)
            ImageDisplayWidget(
              imageBytes: _cameraControllerService.imageBytes!,
              // Setzt das Bild zurück, um ein neues Bild aufzunehmen
              onRetake: () 
              {
                setState(() 
                {
                  _cameraControllerService.resetImage();
                });
              },
            ),
          // Zeigt einen Zurück-Button in der oberen linken Ecke
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}