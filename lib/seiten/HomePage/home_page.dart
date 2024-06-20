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
  final bool demoModus;

  const HomePage({super.key, required this.lehrer, required this.demoModus});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double iconAndTextSize = 26.0;
  static const double cameraIconSize = 120.0;
  List<Klasse> classes = [];
  bool isLoading = true;
  Repository repository = Repository();

  @override
  void initState() {
    super.initState();
    loadClasses();
  }

  void loadClasses() async {
    List<Klasse> fetchedClasses;
    if (widget.demoModus) {
      fetchedClasses = await repository.getClassesFromLocalJson(widget.lehrer.tokenRaw, widget.lehrer.lehrerId);
    } else {
      fetchedClasses = await repository.fetchTeacherClasses(widget.lehrer.tokenRaw, widget.lehrer.lehrerId);
    }

    setState(() {
      classes = fetchedClasses;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(5.0),
        child: const Icon(Icons.person, size: 26.0),
      ),
      title: Text(widget.lehrer.username, style: const TextStyle(fontSize: iconAndTextSize)),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dokument einscannen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildCameraButton(),
          const SizedBox(height: 20),
          const Text('Betreute Klassen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildClassButtons(context),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraPage(token: widget.lehrer.tokenRaw, dmodus: widget.demoModus),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(250, 130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Icon(Icons.camera_alt_rounded, size: cameraIconSize),
      ),
    );
  }

  Widget _buildClassButtons(BuildContext context) {
    if (classes.isEmpty) {
      return const Expanded(
        child: Center(child: Text("Keine Klassen verfügbar", style: TextStyle(fontSize: 16))),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Schuelern(
              klasseId: id,
              token: widget.lehrer.tokenRaw,
              lehrerId: widget.lehrer.lehrerId,
              klasseName: label,
              demoModus: widget.demoModus,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(110, 110),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget build_setting(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'LectorAI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 66,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 45),
            Image.asset('assets/Bilder/lectorAI_Logo.png'),
            const SizedBox(height: 95),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ),
              child: const Text('Einstellungen'),
            ),
          ],
        ),
      ),
    );
  }
}
