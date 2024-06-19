import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lectorai_frontend/seiten/home/home.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuelern.dart';
import 'package:lectorai_frontend/seiten/HomePage/home_page.dart';
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
      create: (_) => ThemeProvider(ThemeData
          .light()), // Initialisiere den ThemeProvider mit einem Standardthema
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          //MaterialApp ist der Startpunkt unserer Anwendung und definiert das grundlegende Design..
          return MaterialApp(
            title: 'LectorAI',
            debugShowCheckedModeBanner: false, //Entfernt das Debug-Banner
            theme: themeProvider
                .themeData, // Verwende das aktuelle Thema aus dem ThemeProvider
            home: const StartPage(),
          );
        },
      ),
    );
  }
}
