import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool no_db = false;
  bool no_change = false;
  bool useDefaultIP = true;
  String serverAddress = '192.168.0.166'; // Default IP-Adresse

  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildServerSetupCard(),
            const SizedBox(height: 20),
            buildThemeToggle(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildServerSetupCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Serversetup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Serveradresse',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabled: !useDefaultIP,
              ),
              style: TextStyle(
                color: useDefaultIP ? Colors.grey : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: useDefaultIP,
                  onChanged: (value) {
                    setState(() {
                      useDefaultIP = value ?? true;
                      if (useDefaultIP) {
                        serverAddress = '192.168.0.166';
                        _ipController.text = serverAddress;
                      }
                      _saveServerAddress();
                    });
                  },
                ),
                const Text('Default IP-Adresse verwenden')
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: useDefaultIP ? null : _saveServerAddress,
                  child: const Text('Speichern'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildCheckboxTile(
              'Datenbankänderungen abrufen',
              no_db,
              (value) => setState(() {
                no_db = value ?? false;
                _saveSettings();
              }),
            ),
            const SizedBox(height: 20),
            buildCheckboxTile(
              'Änderungen nicht übertragen',
              no_change,
              (value) => setState(() {
                no_change = value ?? false;
                _saveSettings();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCheckboxTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget buildThemeToggle() {
    var themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return CupertinoListTile(
      title: const Text('Dark Mode'),
      trailing: CupertinoSwitch(
        value: isDarkMode,
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
            themeProvider.applyTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
            _saveSettings();
          });
        },
      ),
    );
  }

  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      no_db = prefs.getBool('no_db') ?? false;
      no_change = prefs.getBool('no_change') ?? false;
      serverAddress = prefs.getString('serverAddress') ?? '192.168.0.166';
      useDefaultIP = serverAddress == '192.168.0.166';
      _ipController.text = serverAddress;
    });
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    prefs.setBool('no_db', no_db);
    prefs.setBool('no_change', no_change);
    prefs.setString('serverAddress', serverAddress);
  }

  void _saveServerAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!useDefaultIP) {
        serverAddress = _ipController.text;
      }
    });
    prefs.setString('serverAddress', serverAddress);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP-Adresse gespeichert')),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;

  const CupertinoListTile({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var textColor = themeProvider.themeData.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
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
