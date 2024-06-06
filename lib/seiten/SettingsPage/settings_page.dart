import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDemoMode = false; // Zustand für den Demo-Modus

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFB9B5C6), // Gleiche Hintergrundfarbe wie die Login-Seite
      appBar: AppBar(
        title: Text('Einstellungen'),
        backgroundColor:
            Color(0xFFB4C2E6), // Setzt die Hintergrundfarbe der AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Server/Backend-Einstellungen
            ListTile(
              title: Text(
                'Serversetup',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Serveradresse',
                      filled: true,
                      fillColor: Color(0xFFB6CEF9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Demo-Modus
            ListTile(
              title: Text(
                'Demo-Modus',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: Checkbox(
                value: isDemoMode,
                onChanged: (bool? value) {
                  setState(() {
                    isDemoMode = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
