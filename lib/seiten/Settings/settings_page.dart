import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Settings', style: TextStyle(color: Theme.of(context).textTheme.headlineMedium?.color)),
        backgroundColor: CupertinoColors.systemGrey6,
      ),
      child: Container(
        color: CupertinoColors.systemGrey6,
        child: ListView(
          children: [
            buildThemeToggle(),
            const SizedBox(height: 20),
            Center(
              child: CupertinoButton.filled(
                onPressed: _applyTheme,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThemeToggle() {
    return CupertinoListTile(
      title: const Text('Dark Mode'),
      trailing: CupertinoSwitch(
        value: isDarkMode,
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
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
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.black,
            ),
            child: title,
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
