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
      newThemeData = ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1E1D1D),
        scaffoldBackgroundColor: const Color(0xFF1E1D1D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1D1D),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          toolbarTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E1D1D),
          secondary: Colors.amber,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            // Helle Farbe für bessere Sichtbarkeit
            foregroundColor: Colors
                .white, // Weiße Schrift für besseren Kontrast
          ),
        ),
      );
    } else {
      newThemeData = ThemeData.light().copyWith(
        primaryColor: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
          toolbarTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.blueGrey,
          secondary: Colors.orange,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.black,
          ),
        ),
      );
    }

    themeData = newThemeData;
  }
}
