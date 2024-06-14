import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildThemeToggle(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildThemeToggle() {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);  // listen: false hinzugefügt, um unerwünschte Rebuilds zu vermeiden

    return CupertinoListTile(
      title: const Text('Dark Mode'),
      trailing: CupertinoSwitch(
        value: isDarkMode,
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
            // Direktes Anwenden des Themes ohne zusätzlichen Apply-Button
            themeProvider.applyTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
            _saveSettings();
          });
        },
      ),
    );
  }




  void _applyTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.applyTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;

  const CupertinoListTile({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    // Zugriff auf das aktuelle Theme
    var themeProvider = Provider.of<ThemeProvider>(context);
    var textColor = themeProvider.themeData.brightness == Brightness.dark
        ? Colors.white  // Weiße Schrift im Dark Mode
        : Colors.black; // Schwarze Schrift im Light Mode

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
            child: title,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
