class Kontakt {
  String vorname;
  String nachname;
  String telefonnummer;
  String email;

  Kontakt({
    this.vorname = '',
    this.nachname = '',
    this.telefonnummer = '',
    this.email = '',
  });

  factory Kontakt.fromJson(Map<String, dynamic> json) {
    return Kontakt(
      vorname: json['Vorname'],
      nachname: json['Nachname'],
      telefonnummer: json['Telefonnummer'],
      email: json['E-Mail'],
    );
  }
}