class Schueler {
  int id;
  String vorname;
  String nachname;

  Schueler({required this.id, required this.vorname, required this.nachname});

  factory Schueler.fromJson(Map<String, dynamic> json) {
    return Schueler(
      id: json['id'] as int,
      vorname: json['vorname'] as String,
      nachname: json['nachname'] as String,
    );
  }
}