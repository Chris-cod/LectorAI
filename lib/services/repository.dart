import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lectorai_frontend/models/klasse.dart';
import 'package:lectorai_frontend/models/lehrer.dart';
import 'package:lectorai_frontend/models/schueler.dart';

class Repository {
  final String backendURL = 'http://localhost:8000';
  final String LocalUrlAsIp = 'http://192.168.178.52:8000';
  final Lehrer lehrer = Lehrer();
  Klasse klasse = Klasse(klasseId: 0, klasseName: '');

  Future<Lehrer> login(String username, String password) async {
    var url = Uri.parse('$LocalUrlAsIp/login');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body); // Gibt die Daten aus dem JSON-Objekt aus
        lehrer.username = username; // Speichert die Daten in der Lehrerinstanz
        lehrer.tokenRaw = data['token_raw'];
        lehrer.lehrerId = data['person_id'];
        lehrer.isloggedin = true;
        return lehrer; // Anmeldung erfolgreich
      } else {
        print('Failed to login with status code ${response.statusCode}: ${response.body}'); // Gibt Fehlerstatus und Nachricht aus
        return Future.error(response.body); // Anmeldung fehlgeschlagen
      }
    } catch (e) {
      print('Error during login: $e'); // Gibt die Fehlermeldung aus
      return Future.error(e); // Fehler bei der Netzwerkkommunikation
    }
  }
  
  Future<List<Klasse>> fetchTeacherClasses(String authToken, int id) async 
  {
    List<Klasse> classes = [];  // Initialisierung einer leeren Liste für Klassennamen.
    List gettedClasses = []; 
    // Erstellen der vollständigen URL zum Abrufen der Klassen eines bestimmten Lehrers.
    var url = Uri.parse('$LocalUrlAsIp/teacher/$id/classes');
    try 
    {
      // Ausführen der HTTP GET-Anfrage mit Authentifizierungstoken im Header.
      var response = await http.get
      (
        url,
        headers: 
        {
          // Nutzt das zuvor gespeicherte Auth-Token.
          "token": authToken,
        },
      );
      /* Überprüfung, ob der HTTP-Statuscode 200 OK ist, 
       was auf eine erfolgreiche Anfrage hinweist.*/
      if (response.statusCode == 200) 
      {
        var jsonData = json.decode(response.body);
        print(jsonData); // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
        // Überprüfung, ob das JSON-Datenobjekt das Schlüsselwort 'classes' enthält.
        gettedClasses = jsonData['classes'];
        if (gettedClasses.isNotEmpty) 
        { // Casten der Klassennamen in Strings.
          // Durchlaufen aller Einträge in 'classes' und Extrahieren der Klassennamen.
          for (int i = 0; i < gettedClasses.length; i++) 
          {
            klasse.klasseId = gettedClasses[i]['id']; // Extrahieren der Klassen-ID.
            klasse.klasseName = gettedClasses[i]['class_name']; // Extrahieren des Klassennamens.
            classes.add(klasse); // Hinzufügen des Klassennamens zur Liste.
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

 Future<List<Schueler>> getClassStudents(String authToken, int lehrerId, int klasseId) async 
  {
    List<Schueler> students = [];  // Initialisierung einer leeren Liste für Klassennamen.
    List<dynamic> gettedStudent = []; 
    // Erstellen der vollständigen URL zum Abrufen der Klassen eines bestimmten Lehrers.
    var url = Uri.parse('$LocalUrlAsIp/teacher/$lehrerId/class/$klasseId/students');
    try 
    {
      // Ausführen der HTTP GET-Anfrage mit Authentifizierungstoken im Header.
      var response = await http.get
      (
        url,
        headers: 
        {
          // Nutzt das zuvor gespeicherte Auth-Token.
          "token": authToken,
        },
      );
      /* Überprüfung, ob der HTTP-Statuscode 200 OK ist, 
       was auf eine erfolgreiche Anfrage hinweist.*/
      if (response.statusCode == 200) 
      {
        var jsonData = json.decode(response.body); // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
        // Überprüfung, ob das JSON-Datenobjekt das Schlüsselwort 'classes' enthält.
        gettedStudent = jsonData['persons']; // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
        print('response list: $gettedStudent');
        if (gettedStudent.isNotEmpty) 
        { // Casten der Klassennamen in Strings.
          // Durchlaufen aller Einträge in 'classes' und Extrahieren der Klassennamen.
          for (var item in gettedStudent)
          {
            Schueler schueler = Schueler(id : 0, vorname: '', nachname: ''); // Instanzierung eines Schueler-Objekts.
            schueler.id = item['id']; // Extrahieren der Klassen-ID.
            schueler.vorname = item['firstname']; // Extrahieren des Klassennamens.
            schueler.nachname = item['lastname'];
            students.add(schueler); // Hinzufügen des Klassennamens zur Liste.
          }
          for(var item in students)
          {
            print('Vorname: ${item.vorname} Nachname: ${item.nachname}');
          }
          return students;
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
