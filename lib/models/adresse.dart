class Adresse {
  String strasse;
  int hausnummer;
  int postleitzahl;

  Adresse({
    this.strasse = '',
    this.hausnummer = 0,
    this.postleitzahl = 0,
  });

  factory Adresse.fromJson(Map<String, dynamic> json) {
    return Adresse(
      strasse: json['Straße'],
      hausnummer: json['Hausnummer'],
      postleitzahl: json['Postleitzahl'],
    );
  }
}