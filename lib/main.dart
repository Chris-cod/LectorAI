import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_manager.dart';
import 'package:lectorai_frontend/seiten/home/home.dart';
import 'package:provider/provider.dart';
import 'package:lectorai_frontend/seiten/Settings/theme_provider.dart';

void main() async {
  await ConfigLoader.loadEnv();
  runApp(const MyApp());
}

class ConfigLoader {
  static Future<void> loadEnv() async {
    await dotenv.load(fileName: "assets/.env");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager.buildTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LectorAI',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const StartPage(),
          );
        },
      ),
    );
  }
}
