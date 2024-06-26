import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lectorai_frontend/seiten/home/home.dart';
import 'package:provider/provider.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(
        ThemeData.light().copyWith(
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
        ),
      ),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LectorAI',
            debugShowCheckedModeBanner: false, // Entfernt das Debug-Banner
            theme: themeProvider
                .themeData, // Verwende das aktuelle Thema aus dem ThemeProvider
            home: const StartPage(),
          );
        },
      ),
    );
  }
}
