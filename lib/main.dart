import 'package:flutter/material.dart'; // Importiert das Material Design Paket für Flutter.
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importiert das dotenv Paket für das Laden von Umgebungsvariablen.
import 'package:lectorai_frontend/seiten/Settings/theme_manager.dart'; // Importiert den ThemeManager, welcher das Thema der App verwaltet.
import 'package:lectorai_frontend/seiten/home/home.dart'; // Importiert die Startseite der App.
import 'package:provider/provider.dart'; // Importiert das Provider Paket für State Management.
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart'; // Importiert den ThemeProvider, welcher das aktuelle Thema bereitstellt.

void main() async {
  await ConfigLoader
      .loadEnv(); // Lädt die Umgebungsvariablen aus der .env Datei.
  runApp(
      const MyApp()); // Startet die App und verwendet MyApp als Wurzel-Widget.
}

class ConfigLoader {
  static Future<void> loadEnv() async {
    await dotenv.load(
        fileName:
            "assets/.env"); // Lädt die .env Datei aus dem angegebenen Pfad.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktor für die MyApp Klasse.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager
          .buildTheme(), // Erstellt eine Instanz von ThemeManager und stellt sie als ChangeNotifier zur Verfügung.
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LectorAI', // Setzt den Titel der App.
            debugShowCheckedModeBanner:
                false, // Entfernt das Debug-Banner in der oberen rechten Ecke.
            theme: themeProvider
                .themeData, // Setzt das Thema der App auf das vom ThemeProvider bereitgestellte Thema.
            home:
                const StartPage(), // Setzt die Startseite der App auf StartPage.
          );
        },
      ),
    );
  }
}
