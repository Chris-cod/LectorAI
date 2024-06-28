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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Hintergrundfarbe
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
        
        // Your dark mode theme data here
      );
    }

    themeData = newThemeData;
    notifyListeners();
  }
}
