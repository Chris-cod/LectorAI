class Klasse {
  int klasseId;
  String klasseName;
  

  Klasse({
    required this.klasseId,
    required this.klasseName,
  });

  factory Klasse.fromJson(Map<String, dynamic> json) {
    return Klasse(
      klasseId: json['klasseId'],
      klasseName: json['klasseName'],
    );
  }
}