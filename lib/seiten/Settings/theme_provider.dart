import 'package:flutter/material.dart'; // Importiert das Material Design Paket für Flutter.

/* 
 * Diese Klasse verwaltet das Thema der Anwendung und ermöglicht das Umschalten zwischen
 * hellem und dunklem Modus. Sie erweitert `ChangeNotifier`, sodass Widgets, die auf diese
 * Klasse hören, benachrichtigt werden, wenn sich das Thema ändert.
*/

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData; // Interne Variable für das aktuelle Thema.

  ThemeProvider(this._themeData); // Konstruktor, der das Anfangsthema setzt.

  ThemeData get themeData => _themeData; // Getter für das aktuelle Thema.

  // Setzt das aktuelle Thema der Anwendung und benachrichtigt die Zuhörer über die Änderung.
  set themeData(ThemeData themeData) {
    _themeData = themeData; // Setzt das neue Thema.
    notifyListeners(); // Benachrichtigt alle Listener über die Änderung.
  }

  /* 
   * Wendet das angegebene Thema an (hell oder dunkel) und aktualisiert das `ThemeData`
   * entsprechend. Benachrichtigt die Zuhörer über die Änderung.
  */
  void applyTheme(ThemeMode mode) {
    ThemeData newThemeData; // Variable für das neue Thema.

    if (mode == ThemeMode.dark) {
      // Dark Mode
      newThemeData = ThemeData.dark();
    } else {
      newThemeData = ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFB9B5C6), // Hintergrundfarbe
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color.fromARGB(255, 233, 229, 240), // Farbe der AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Color.fromARGB(255, 233, 229, 240), // Farbe der ElevatedButtons
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor:
              Color.fromARGB(255, 233, 229, 240), // Füllfarbe der Eingabefelder
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
                25.0), // Abgerundete Ecken der Eingabefelder
            borderSide: BorderSide.none, // Keine Rahmenlinie
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 116, 82, 163), // Farbe der Icons
        ),
      );
    }

    themeData = newThemeData; // Setzt das neue Thema.
    notifyListeners(); // Benachrichtigt alle Listener über die Änderung.
  }
}
