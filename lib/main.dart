import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/home/home.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuelern.dart';
import 'package:lectorai_frontend/seiten/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    //MaterialApp ist der Startpunkt unserer Anwendung und definiert das grundlegende Design.
    return const MaterialApp
    (
      title: 'LectorAI',
      debugShowCheckedModeBanner: false, //Entfernt das Debug-Banner
      home: StartPage(),
    );
  }
}