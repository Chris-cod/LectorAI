import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void applyTheme(ThemeMode mode) {
    ThemeData newThemeData;

    if (mode == ThemeMode.dark) {
      // Dark mode
      newThemeData = ThemeData.dark();
    } else {
      // Light mode
      newThemeData = ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFB9B5C6), // Hintergrundfarbe
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB9B5C6), // AppBar-Farbe
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB6CEF9), // Button-Farbe
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFB6CEF9), // Eingabefeld-Farbe
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    themeData = newThemeData;
    notifyListeners();
  }
}
