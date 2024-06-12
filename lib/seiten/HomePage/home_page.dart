import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lectorai_frontend/models/klasse.dart';
import 'package:lectorai_frontend/models/lehrer.dart';
import 'package:lectorai_frontend/seiten/CamerPage/camera_page.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuelern.dart';
import 'package:lectorai_frontend/services/repository.dart';
import 'package:lectorai_frontend/seiten/Settings/settings_page.dart';


class HomePage extends StatefulWidget {
  final Lehrer lehrer;

  const HomePage({super.key, required this.lehrer});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double iconAndTextSize = 36.0;
  static const double cameraIconSize = 120.0;
  List<Klasse> classes = [];
  bool isLoading = true;  // Anzeigen eines Ladeindikators
  Repository repository = Repository(); // Erstellung einer Instanz der Repository-Klasse

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadClasses() async {
    var fetchedClasses = await repository.fetchTeacherClasses(widget.lehrer.tokenRaw, widget.lehrer.lehrerId);
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
      body: isLoading ? Center(child: CircularProgressIndicator()) : _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      //backgroundColor: const Color(0xFF48CAE4),
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: const Icon(Icons.person, size: 48.0),
      ),
      title: Text(widget.lehrer.username, style: TextStyle(fontSize: iconAndTextSize)),

      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage())
            );
          },
        ),
      ],
    );

  }

  Widget _buildBody(BuildContext context) {
    return Container(
      //color: const Color(0xFF0077B6),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dokument einscannen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
     //     const Divider(color: Colors.black),
          _buildCameraButton(),
          const Text('Betreute Klassen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    //      const Divider(color: Colors.black),
          _buildClassButtons(context),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
                    print("Kamera-Button gedrückt");
                    // Verwenden des Navigators zum Öffnen der CameraPage
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CameraPage(token: widget.lehrer.tokenRaw)),
                      );
                    },
          child: Container(
            width: 250,
            height: 130,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
          //    color: const Color(0xff48CAE4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Icon(Icons.camera_alt_rounded, size: cameraIconSize)),
          ),
        ),
      ),
    );
  }

  Widget _buildClassButtons(BuildContext context) {
    if (classes.isEmpty) {
      return const Expanded(
        child: Center(child: Text("Keine Klassen verfügbar")),
      );
    }
    return Expanded(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 15,
          children: classes.map((className) => _buildClassButton(className.klasseName, context)).toList(),
        ),
      ),
    );
  }

  Widget _buildClassButton(String label, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final int id = classes.firstWhere((element) => element.klasseName == label).klasseId;
        print("Button $label wurde gedrückt.");
        Navigator.push(context, MaterialPageRoute(builder: (context) => Schuelern(klasseId: id, token: widget.lehrer.tokenRaw, lehrerId: widget.lehrer.lehrerId, klasseName: label,)));
      },
      style: ElevatedButton.styleFrom(
    //    foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Textfarbe
   //     backgroundColor: const Color(0xff48CAE4), // Hintergrundfarbe
        minimumSize: const Size(110, 110), // Minimale Größe
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Abgerundete Ecken
      ),
      child: Text(label, style: const TextStyle(fontSize: 38)), // Text des Buttons
    );
  }

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
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage())
                ),
                child: const Text('Einstellungen')
            ),
          ],
        ),
      ),
    );
  }
}
