import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';

class ThemeManager {
  static ThemeProvider buildTheme() {
    return ThemeProvider(
      ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 233, 229, 240),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 233, 229, 240),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 233, 229, 240),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 116, 82, 163),
        ),
      ),
    );
  }
}
