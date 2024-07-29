import 'package:flutter/cupertino.dart'; // Importiert Cupertino Widgets für iOS-Design.
import 'package:shared_preferences/shared_preferences.dart'; // Importiert das SharedPreferences Paket zum Speichern und Laden von Einstellungen.
import 'package:flutter/material.dart'; // Importiert das Material Design Paket für Flutter.
import 'package:provider/provider.dart'; // Importiert das Provider Paket für State Management.
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart'; // Importiert den ThemeProvider für das App-Thema.

/* Diese Seite bietet verschiedene Einstellungen für die Anwendung, einschließlich 
 * der Möglichkeit, den Server zu konfigurieren und den Dark Mode zu aktivieren.
*/
class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,
      required this.loggedIn}); // Konstruktor für die SettingsPage Klasse mit einer loggedIn Eigenschaft.
  final bool
      loggedIn; // Boolean-Variable, die angibt, ob der Benutzer eingeloggt ist.

  @override
  _SettingsPageState createState() =>
      _SettingsPageState(); // Erstellt den Zustand der SettingsPage.
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false; // Variable für den Dark Mode Status.
  bool desableDbComparison =
      false; // Variable, ob die Datenbankvergleichsfunktion deaktiviert ist.
  bool dontSaveChanges =
      false; // Variable, ob Änderungen gespeichert werden sollen.
  bool useDefaultIP = true; // Variable, ob die Standard-IP verwendet wird.
  String serverAddress = '192.168.0.166'; // Standard-IP-Adresse.

  final TextEditingController _ipController =
      TextEditingController(); // Textfeld-Controller für die Serveradresse.

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Lädt die gespeicherten Einstellungen beim Initialisieren.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'), // Titel der App-Leiste.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildServerSetupCard(), // Baut die Karte für das Server-Setup.
            const SizedBox(height: 20),
            buildThemeToggle(), // Baut den Umschalter für das Thema.
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /* Baut die Karte für die Servereinstellungen, die es dem Benutzer ermöglicht, 
   * die IP-Adresse des Servers zu konfigurieren und andere Einstellungen vorzunehmen.
  */
  Widget buildServerSetupCard() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10)), // Runden die Ecken der Karte ab.
      elevation: 5, // Setzt die Elevation der Karte.
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Serversetup',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold), // Stil für den Titel des Server-Setups.
            ),
            const SizedBox(height: 10),
            TextField(
              controller:
                  _ipController, // Verwendet den Textfeld-Controller für die Eingabe der Serveradresse.
              decoration: InputDecoration(
                labelText: 'Serveradresse',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Rundet die Ecken des Textfeldes ab.
                ),
                enabled:
                    !useDefaultIP, // Deaktiviert das Textfeld, wenn die Standard-IP verwendet wird.
              ),
              style: TextStyle(
                color: useDefaultIP
                    ? Colors.grey
                    : Colors
                        .black, // Setzt die Textfarbe basierend auf der IP-Nutzung.
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value:
                      useDefaultIP, // Setzt den Wert des Kontrollkästchens auf useDefaultIP.
                  onChanged: (value) {
                    setState(() {
                      useDefaultIP = value ?? true;
                      if (useDefaultIP) {
                        serverAddress =
                            '192.168.0.166'; // Setzt die Serveradresse auf die Standard-IP.
                        _ipController.text = serverAddress;
                      }
                      _saveServerAddress(); // Speichert die Serveradresse.
                    });
                  },
                ),
                const Text(
                    'Default IP-Adresse verwenden') // Text für das Kontrollkästchen.
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: useDefaultIP
                      ? null
                      : _saveServerAddress, // Deaktiviert den Button, wenn die Standard-IP verwendet wird.
                  child: const Text('Speichern'), // Beschriftung des Buttons.
                ),
              ],
            ),
            const SizedBox(height: 20),
            buildCheckboxTile(
              'KI Ergebnis abrufen',
              desableDbComparison, // Setzt den Wert des Kontrollkästchens auf desableDbComparison.
              (value) => setState(() {
                desableDbComparison = value ?? false;
                _saveSettings(); // Speichert die Einstellungen.
              }),
            ),
            const SizedBox(height: 20),
            buildCheckboxTile(
              'Änderungen nicht übertragen',
              dontSaveChanges, // Setzt den Wert des Kontrollkästchens auf dontSaveChanges.
              (value) => setState(() {
                dontSaveChanges = value ?? false;
                _saveSettings(); // Speichert die Einstellungen.
              }),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildCheckboxTile(
      String title, bool value, ValueChanged<bool?> onChanged) {
    if (widget.loggedIn) {
      // Zeigt das Kontrollkästchen nur an, wenn der Benutzer eingeloggt ist.

      return ListTile(
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 16), // Stil für den Titel des Kontrollkästchens.
        ),
        trailing: Checkbox(
          value: value, // Setzt den Wert des Kontrollkästchens.
          onChanged:
              onChanged, // Funktion, die bei Änderung des Wertes aufgerufen wird.
        ),
      );
    } else {
      return Container(); // Gibt ein leeres Container zurück, wenn der Benutzer nicht eingeloggt ist.
    }
  }
 
  /* Baut das Umschaltelement für den Dark Mode, das es dem Benutzer ermöglicht, 
   * zwischen hellen und dunklen Themen zu wechseln.
  */
  Widget buildThemeToggle() {
    var themeProvider = Provider.of<ThemeProvider>(context,
        listen: false); // Holt den ThemeProvider.

    return CupertinoListTile(
      title: const Text('Dark Mode'), // Titel für den Umschalter.
      trailing: CupertinoSwitch(
        value: isDarkMode, // Setzt den Wert des Schalters auf isDarkMode.
        onChanged: (value) {
          setState(() {
            isDarkMode = value;
            themeProvider.applyTheme(isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light); // Wendet das gewählte Thema an.
            _saveSettings(); // Speichert die Einstellungen.
          });
        },
      ),
    );
  }

  // Lädt die gespeicherten Einstellungen aus dem lokalen Speicher.
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Lädt die gespeicherten Einstellungen.
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      desableDbComparison = prefs.getBool('desableDbComparison') ?? false;
      dontSaveChanges = prefs.getBool('dontSaveChanges') ?? false;
      serverAddress = prefs.getString('serverAddress') ?? '192.168.0.166';
      useDefaultIP = serverAddress == '192.168.0.166';
      _ipController.text = serverAddress;
    });
  }
  // Speichert die aktuellen Einstellungen im lokalen Speicher.
  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Speichert die aktuellen Einstellungen.
    prefs.setBool('isDarkMode', isDarkMode);
    prefs.setBool('desableDbComparison', desableDbComparison);
    prefs.setBool('dontSaveChanges', dontSaveChanges);
    prefs.setString('serverAddress', serverAddress);
  }

  /* Speichert die aktuelle Serveradresse im lokalen Speicher und zeigt eine 
   * Bestätigungsmeldung an.
  */
  void _saveServerAddress() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // Speichert die aktuelle Serveradresse.
    setState(() {
      if (!useDefaultIP) {
        serverAddress = _ipController.text;
      }
    });
    prefs.setString('serverAddress', serverAddress);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'IP-Adresse gespeichert')), // Zeigt eine Snackbar an, wenn die IP-Adresse gespeichert wurde.
    );
  }
}

/* Ein benutzerdefiniertes Listenelement im Cupertino-Stil, das eine Titel- und
 * eine Trailing-Komponente enthält.
*/
class CupertinoListTile extends StatelessWidget {
  final Widget title;
  final Widget? trailing;

  const CupertinoListTile(
      {super.key,
      required this.title,
      this.trailing}); // Konstruktor für die CupertinoListTile Klasse.

  @override
  Widget build(BuildContext context) {
    var themeProvider =
        Provider.of<ThemeProvider>(context); // Holt den ThemeProvider.
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
          if (trailing != null)
            trailing!, // Zeigt das trailing Widget, falls vorhanden.
        ],
      ),
    );
  }
}
