import 'dart:convert';
import 'package:http/http.dart' as http;

class Repository {
  String authToken = '';
  String backendURL = 'http://localhost:8000';
  String LocalUrlAsIp = 'http://192.168.178.52:8000';
  int lehrerId = 0;

  Future<bool> login(String username, String password) async {
    var url = Uri.parse('$LocalUrlAsIp/login');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        lehrerId = data['person_id'];
        //authToken = data['token_raw']; // Speichert das 'token_full'
        //print('Token: ${data['token_raw']}'); // Zeigt das 'token_raw' für Debug-Zwecke
        authToken = data['token_raw']; // Speichert das 'token_full' korrekt mit Bearer
        print('Token: ${data['token_raw']}'); // Zeigt das 'token_full' für Debug-Zwecke
        return true; // Anmeldung erfolgreich
      } else {
        print(
            'Failed to login with status code ${response.statusCode}: ${response.body}'); // Gibt Fehlerstatus und Nachricht aus
        return false; // Anmeldung fehlgeschlagen
      }
    } catch (e) {
      print('Error during login: $e'); // Gibt die Fehlermeldung aus
      return false; // Fehler bei der Netzwerkkommunikation
    }
  }
  
  Future<List<String>> fetchTeacherClasses() async 
  {
    // Erstellen der vollständigen URL zum Abrufen der Klassen eines bestimmten Lehrers.
    var url = Uri.parse('$LocalUrlAsIp/teacher/$lehrerId/classes');
    try 
    {
      // Ausführen der HTTP GET-Anfrage mit Authentifizierungstoken im Header.
      var response = await http.get
      (
        url,
        headers: 
        {
          // Nutzt das zuvor gespeicherte Auth-Token.
          "Authorization": authToken,
        },
      );
      /* Überprüfung, ob der HTTP-Statuscode 200 OK ist, 
       was auf eine erfolgreiche Anfrage hinweist.*/
      if (response.statusCode == 200) 
      {
        var jsonData = json.decode(response.body);
        // Überprüfung, ob das JSON-Datenobjekt das Schlüsselwort 'classes' enthält.
        if (jsonData != null && jsonData.containsKey('classes')) 
        {
          List<String> classes = [];  // Initialisierung einer leeren Liste für Klassennamen.
          // Durchlaufen aller Einträge in 'classes' und Extrahieren der Klassennamen.
          for (var item in jsonData['classes']) 
          {
            classes.add(item['class_name']); // Hinzufügen des Klassennamens zur Liste.
          }
          return classes;
         } 
         else 
         {
          // Wenn die Daten unvollständig sind oder das Schlüsselwort 'classes' fehlt,
          // wird eine Warnung ausgegeben und eine leere Liste zurückgegeben.
          print('Data is incomplete or not as expected');
          return []; 
       }
     } 
      else 
      {
        // Bei jedem anderen Statuscode als 200 wird eine Fehlermeldung ausgegeben.
        print("Fehler beim Abrufen der Daten: ${response.statusCode}");
        return [];
      }
    } 
    catch (e) 
    {
      // Fangen von Ausnahmen, die während der HTTP-Anfrage auftreten können,
      // und Ausgabe einer Fehlermeldung.
      print("Exception caught: $e");
      return [];
    }
 }
}
