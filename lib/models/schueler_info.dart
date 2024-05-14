import 'package:lectorai_frontend/models/adresse.dart';
import 'package:lectorai_frontend/models/kontakt.dart';

class SchuelerInfo{
  String vorname;
  String nachname;
  Adresse adresse;
  int id;
  String klasse;
  List<String> ags;
  Kontakt kontakt;

  SchuelerInfo({
    this.vorname = '',
    this.nachname = '',
    this.id = 0,
    required this.adresse ,
    this.klasse = '',
    this.ags = const [],
    required this.kontakt,
  });

  factory SchuelerInfo.fromJson(Map<String, dynamic> json) {
    return SchuelerInfo(
      vorname: json['Vorname'],
      nachname: json['Nachname'],
      id: json['ID'],
      adresse: Adresse.fromJson(json['Adresse']),
      klasse: json['Klasse'],
      ags: List<String>.from(json['AGs']),
      kontakt: Kontakt.fromJson(json['Kontakt']),
    );
  }
}