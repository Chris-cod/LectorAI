class Lehrer{
  String username;
  String tokenRaw;
  int lehrerId;
  bool isloggedin;



  Lehrer({
    this.username = '',
    this.tokenRaw = '',
    this.lehrerId = 0,
    this.isloggedin = false,
  });

  // factory Lehrer.fromJson(Map<String, dynamic> json){
  //   return Lehrer(
  //     token_full: json['token_full'],
  //     token_raw: json['token_raw'],
  //     lehrerId: json['person_id'],
  //   );
  // }
}