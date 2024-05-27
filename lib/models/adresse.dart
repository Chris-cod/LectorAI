class Adresse {
  String strasse;
  String hausnummer;
  int postleitzahl;
  String ort;

  Adresse({
    this.strasse = '',
    this.hausnummer = '',
    this.postleitzahl = 0,
    this.ort = '',
  });

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      strasse: json['Straße'],
      hausnummer: json['Hausnummer'],
      postleitzahl: json['Postleitzahl'],
    );
  }
}