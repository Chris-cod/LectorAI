import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuelern.dart';
import 'package:lectorai_frontend/services/repository.dart';


class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double iconAndTextSize = 36.0;
  static const double cameraIconSize = 120.0;
  List<String> classes = [];
  bool isLoading = true;  // Anzeigen eines Ladeindikators
  Repository repository = Repository(); // Erstellung einer Instanz der Repository-Klasse

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadClasses() async {
    bool isLoggedIn = await repository.login('username', 'password'); // Passen Sie dies an
    if (isLoggedIn) {
      var fetchedClasses = await repository.fetchTeacherClasses();
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
      backgroundColor: const Color(0xFF48CAE4),
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: const Icon(Icons.person, size: 48.0),
      ),
      title: Text(widget.username, style: TextStyle(fontSize: iconAndTextSize)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: const Color(0xFF0077B6),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dokument einscannen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black),
          _buildCameraButton(),
          const Text('Betreute Klassen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black),
          _buildClassButtons(context),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () => print("Kamera-Button gedrückt"),
          child: Container(
            width: 250,
            height: 130,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: const Color(0xff48CAE4),
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
          children: classes.map((className) => _buildClassButton(className, context)).toList(),
        ),
      ),
    );
  }

  Widget _buildClassButton(String label, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print("Button $label wurde gedrückt.");
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Schuelern()));
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Textfarbe
        backgroundColor: const Color(0xff48CAE4), // Hintergrundfarbe
        minimumSize: const Size(110, 110), // Minimale Größe
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Abgerundete Ecken
      ),
      child: Text(label, style: const TextStyle(fontSize: 38)), // Text des Buttons
    );
  }
}
