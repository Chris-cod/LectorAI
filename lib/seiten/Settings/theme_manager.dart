import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';

/* 
 * Diese Klasse verwaltet das Thema der Anwendung. Sie stellt eine Methode 
 * zur Verfügung, um ein benutzerdefiniertes Thema für die App zu erstellen.
*/
class ThemeManager {
  /* 
  * Erstellt und gibt ein `ThemeProvider` zurück, der ein benutzerdefiniertes  
  * helles Thema enthält. Das Thema umfasst Anpassungen für verschiedene UI-Komponenten
  * wie den Hintergrund der Scaffold, die AppBar, ElevatedButtons, Eingabefelder und Icons.
  */
  static ThemeProvider buildTheme() {
    return ThemeProvider(
      ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFB9B5C6),
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
