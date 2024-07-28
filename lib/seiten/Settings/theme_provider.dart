import 'package:flutter/material.dart';

/* 
 * Diese Klasse verwaltet das Thema der Anwendung und ermöglicht das Umschalten zwischen
 * hellem und dunklem Modus. Sie erweitert `ChangeNotifier`, sodass Widgets, die auf diese
 * Klasse hören, benachrichtigt werden, wenn sich das Thema ändert.
*/

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  // Gibt das aktuelle Thema der Anwendung zurück.
  ThemeData get themeData => _themeData;

  // Setzt das aktuelle Thema der Anwendung und benachrichtigt die Zuhörer über die Änderung.
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  /* 
   * Wendet das angegebene Thema an (hell oder dunkel) und aktualisiert das `ThemeData`
   * entsprechend. Benachrichtigt die Zuhörer über die Änderung.
  */
  void applyTheme(ThemeMode mode) {
    ThemeData newThemeData;

    if (mode == ThemeMode.dark) {
      // Dark mode
      newThemeData = ThemeData.dark();
    } else {
      // Heller Modus
      newThemeData = ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFB9B5C6), // Hintergrundfarbe
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 233, 229, 240),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 233, 229, 240),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color.fromARGB(255, 233, 229, 240),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 116, 82, 163),
        ),
      );
    }
    
    themeData = newThemeData;
    notifyListeners();
  }
}
