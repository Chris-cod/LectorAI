import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/BlattView/Pdfviewr.dart';
import 'dart:typed_data';
import 'dart:ui';
//import 'package:lectorai_frontend/seiten/CamerPage/UploadPage.dart';

class ImageDisplayWidget extends StatelessWidget 
{
  final Uint8List imageBytes;
  final VoidCallback onRetake;
  final String token;
  final bool test; 
  
   ImageDisplayWidget({super.key,required this.imageBytes, required this.onRetake, required this.token, required this.test});

  @override
  Widget build(BuildContext context) 
  {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,  // Das Bild füllt den gesamten verfügbaren Platz aus
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
        Center(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Positioniert die Schaltflächen unten zentriert
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: ()
                  {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () 
                  {
                    // Navigiert zur PdfViwer und übergibt die imageBytes
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfViwer(authToken: token, imageBytes: imageBytes, demoModus: test),
                      ),
                    );
                  },
                  child: const Text('KI-Analyse starten'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}