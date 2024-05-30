import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/BlattView/Pdfviewr.dart';
import 'dart:typed_data';
import 'package:lectorai_frontend/seiten/CamerPage/UploadPage.dart';


class ImageDisplayWidget extends StatelessWidget 
{
  final Uint8List imageBytes;
  final VoidCallback onRetake;
  final String token;

  const ImageDisplayWidget({super.key, required this.imageBytes, required this.onRetake, required this.token});

  @override
  Widget build(BuildContext context) 
  {
    return Stack(
      children: [
        Center(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,  // Das Bild füllt den gesamten verfügbaren Platz aus
            width: double.infinity,
            height: double.infinity,
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
                // Schaltfläche zum Wiederholen
                ElevatedButton(
                  onPressed: onRetake,
                  child: const Text('Wiederholen'),
                ),
                // Schaltfläche zum Hochladen
                ElevatedButton(
                  onPressed: () 
                  {
                    // Navigiert zur UploadPage und übergibt die imageBytes
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfViwer(authToken: token,imageBytes: imageBytes),
                      ),
                    );
                  },
                  child: const Text('Hochladen'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
