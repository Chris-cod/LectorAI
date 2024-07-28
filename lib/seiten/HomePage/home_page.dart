import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lectorai_frontend/models/klasse.dart';
import 'package:lectorai_frontend/models/lehrer.dart';
import 'package:lectorai_frontend/seiten/CamerPage/camera_page.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuelern.dart';
import 'package:lectorai_frontend/services/repository.dart';
import 'package:lectorai_frontend/seiten/Settings/settings_page.dart';

/*
 * Autor: Ayham
 * Fakultät: TI
 * Matrikelnummer: 5188947
 * Fachsemester: 6
 * 
 * Dies ist die Hauptseite der Anwendung, die die Benutzeroberfläche für Lehrer darstellt.
 * Die Seite zeigt verschiedene Funktionen, wie das Scannen von Dokumenten und die 
 * Anzeige der betreuten Klassen.
*/

class HomePage extends StatefulWidget {
  final Lehrer lehrer;
  final bool demoModus;

  const HomePage({super.key, required this.lehrer, required this.demoModus});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double iconAndTextSize = 36.0;
  static const double cameraIconSize = 120.0;
  List<String> classes = [];
  bool isLoading = true; // Anzeigen eines Ladeindikators
  Repository repository =
      Repository(); // Erstellung einer Instanz der Repository-Klasse

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  /*
   * Lädt die Klassen entweder aus einer lokalen JSON-Datei (im Demo-Modus) 
   *  oder vom Server (wenn nicht im Demo-Modus).
  */ 
  void loadClasses() async {
    List<String> fetchedClasses = [];
    if (widget.demoModus) {
      fetchedClasses = await repository.getClassesFromLocalJson();
    } else {
      fetchedClasses = await repository.fetchTeacherClasses(widget.lehrer.token);
    }

    if (fetchedClasses.isNotEmpty) {
      setState(() {
        classes = fetchedClasses;
        isLoading = false;
      });
    } else {
      // Fehlerbehandlung, z. B. Anzeigen einer Nachricht, dass das Laden fehlgeschlagen ist
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  /*
   * Erstellt die AppBar der Seite mit dem Benutzernamen des Lehrers und einem
   * Einstellungs-Button.
  */ 
  AppBar _buildAppBar() {
    return AppBar(
      //backgroundColor: const Color(0xFF48CAE4),
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: const Icon(Icons.person, size: 48.0),
      ),
      title: Text(widget.lehrer.username,
          style: TextStyle(fontSize: iconAndTextSize)),

      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(loggedIn: widget.lehrer.isloggedin))
            );
          },
        ),
      ],
    );
  }

  /*
   * Erstellt den Hauptteil der Seite, der die Schaltflächen zum Scannen von Dokumenten
   * und zur Anzeige der betreuten Klassen enthält.
  */ 
  Widget _buildBody(BuildContext context) {
    return Container(
      //color: const Color(0xFF0077B6),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dokument einscannen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          //     const Divider(color: Colors.black),
          _buildCameraButton(),
          const Text('Betreute Klassen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          //      const Divider(color: Colors.black),
          _buildClassButtons(context),
        ],
      ),
    );
  }

  // Erstellt die Schaltfläche zum Öffnen der Kamera-Seite.
  Widget _buildCameraButton() {
    return Expanded(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            print("Kamera-Button gedrückt");
            // Verwenden des Navigators zum Öffnen der CameraPage
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CameraPage(
                        token: widget.lehrer.token,
                        dmodus: widget.demoModus,
                      )),
            );
          },
          style: ElevatedButton.styleFrom(
            //primary: const Color(0xff48CAE4), // Hintergrundfarbe des Buttons
            minimumSize: const Size(250, 130), // Größe des Buttons
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)), // Abgerundete Ecken
          ),
          child: const Icon(Icons.camera_alt_rounded,
              size: 120.0, ), // Das Icon in der Mitte des Buttons
        ),
      ),
    );
  }


  /*
   * Erstellt die Schaltflächen für die betreuten Klassen. 
   *  Wenn keine Klassen verfügbar sind, wird eine entsprechende Nachricht angezeigt.
  */ 
  Widget _buildClassButtons(BuildContext context) {
    if (classes.isEmpty) {
      return const Expanded(
        child: Center(child: Text("Keine Klassen verfügbar")),
      );
    }
    return Expanded(
      child: Align(
      alignment: Alignment.bottomCenter, // Positioniert den Inhalt am unteren Rand des Bildschirms
      child: Container(
        height: MediaQuery.of(context).size.height * 0.36, // Setzt die Höhe auf ein Viertel der Bildschirmhöhe
        width: MediaQuery.of(context).size.width, // Setzt die Breite auf die Breite des Bildschirms
        child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 15,
          children: classes
              .map((className) =>
                  _buildClassButton(className, context))
              .toList(),
        ),
      ),
      ),
      ),
    );
  }

  /*
   * Erstellt eine einzelne Schaltfläche für eine Klasse, die beim Drücken 
   * die Seite für die Schüler dieser Klasse öffnet.
  */ 
  Widget _buildClassButton(String label, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print("Button $label wurde gedrückt.");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Schuelern(
                      token: widget.lehrer.token,
                      klasseName: label,
                      demoModus: widget.demoModus,
                    )));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(110, 110), // Minimale Größe
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)), // Abgerundete Ecken
      ),
      child:
          Text(label, style: const TextStyle(fontSize: 38)), // Text des Buttons
    );
  }

  // Erstellt die Einstellungsseite.
  Widget build_setting(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF0077B6),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'LectorAI',
              textAlign: TextAlign.center,
              style: TextStyle(
                  //           color: Colors.white, // Anpassung der Textfarbe zu Weiß
                  fontSize: 66,
                  fontWeight: FontWeight.bold // Optional: Fettdruck hinzufügen
                  ),
            ),
            const SizedBox(height: 45),
            Image.asset('assets/Bilder/lectorAI_Logo.png'),
            const SizedBox(height: 95),
            ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage(loggedIn: widget.lehrer.isloggedin))),
                child: const Text('Einstellungen')),
          ],
        ),
      ),
    );
  }
}