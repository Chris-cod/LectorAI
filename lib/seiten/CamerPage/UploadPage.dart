import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/CamerPage/ViewImagePage.dart';


class UploadPage extends StatelessWidget 
{
  final Uint8List imageBytes; // Nimmt das Byte-Array auf

  const UploadPage({Key? key, required this.imageBytes}) : super(key: key);

  Widget build(BuildContext context) 
  {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.02,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // Dialog anzeigen
                  showDialog(
                    context: context,
                    builder: (BuildContext context) 
                    {
                      return AlertDialog(
                        title: Text('Abbrechen?'),
                        content: Text('Sind Sie sicher, dass Sie den Prozess abbrechen möchten?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Nein'),
                            onPressed: () 
                            {
                              // Dialog schließen
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Ja'),
                            onPressed: () 
                            {
                              // Dialog schließen und zweimalige Rücknavigation
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: screenHeight * 0.05,
              left: (screenWidth / 2) - (screenWidth * 0.1 / 2),
              child: IconButton(
                icon: Icon(Icons.remove_red_eye, size: screenWidth * 0.1),
                onPressed: () 
                {
                  // Navigieren zur ViewImagePage mit dem Byte-Array
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ViewImagePage(imageBytes: imageBytes)
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
