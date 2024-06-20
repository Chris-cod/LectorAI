import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lectorai_frontend/models/adresse.dart';
import 'package:lectorai_frontend/models/klasse.dart';
import 'package:lectorai_frontend/models/kontakt.dart';
import 'package:lectorai_frontend/models/lehrer.dart';
import 'package:lectorai_frontend/models/schueler.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';

class Repository {
  final String backendURL = 'http://localhost:8000';
  final String LocalUrlAsIp = 'http://${dotenv.env['LOCALE_IP']!}:8000';
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
        var data =
            jsonDecode(response.body); // Gibt die Daten aus dem JSON-Objekt aus
        lehrer.username = username; // Speichert die Daten in der Lehrerinstanz
        lehrer.tokenRaw = data['token_raw'];
        lehrer.lehrerId = data['person_id'];
        lehrer.isloggedin = true;
        return lehrer; // Anmeldung erfolgreich
      } else {
        print(
            'Failed to login with status code ${response.statusCode}: ${response.body}'); // Gibt Fehlerstatus und Nachricht aus
        return Future.error(response.body); // Anmeldung fehlgeschlagen
      }
    } catch (e) {
      print('Error during login: $e'); // Gibt die Fehlermeldung aus
      return Future.error(e); // Fehler bei der Netzwerkkommunikation
    }
  }


  /* Logs in a user using local JSON data.
   This method loads a JSON file from the assets folder and decodes it into a Dart object.
   It then compares the provided username and password with the data from the JSON file.
   If the username and password match, it populates a `Lehrer` instance with the data
   from the JSON file and returns it. Otherwise, it throws an error indicating
   incorrect username or password.
   Returns a `Future` that completes with a `Lehrer` instance if the login is successful,
   or throws an error if the login fails.*/
  Future<Lehrer> loginFromLocalJson(String username, String password) async {
    var jsonString = await rootBundle.loadString(
        'assets/Daten/user_and_passwort_test.json'); // Lädt die JSON-Datei aus Assets
    var jsonResponse = jsonDecode(jsonString); // Decodiert die JSON-String zu einem Dart-Objekt

    if (username == jsonResponse['username'] &&
        password == jsonResponse['password']) {
      lehrer.username = jsonResponse["teacher_name"]; // Speichert die Daten in der Lehrerinstanz
      lehrer.tokenRaw = jsonResponse['token_raw'];
      lehrer.lehrerId = jsonResponse['id'];
      lehrer.isloggedin = true;
      return lehrer; // Anmeldung erfolgreich
    } else {
      return Future.error('Falscher Benutzername oder Passwort');
    }
  }

  Future<List<Klasse>> fetchTeacherClasses(String authToken, int id) async {
    List<Klasse> classes =
        []; // Initialisierung einer leeren Liste für Klassennamen.
    List gettedClasses = [];
    // Erstellen der vollständigen URL zum Abrufen der Klassen eines bestimmten Lehrers.
    var url = Uri.parse('$LocalUrlAsIp/teacher/$id/classes');
    try {
      // Ausführen der HTTP GET-Anfrage mit Authentifizierungstoken im Header.
      var response = await http.get(
        url,
        headers: {
          // Nutzt das zuvor gespeicherte Auth-Token.
          "token": authToken,
        },
      );
      /* Überprüfung, ob der HTTP-Statuscode 200 OK ist, 
       was auf eine erfolgreiche Anfrage hinweist.*/
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print(jsonData); // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
        // Überprüfung, ob das JSON-Datenobjekt das Schlüsselwort 'classes' enthält.
        gettedClasses = jsonData['classes'];
        if (gettedClasses.isNotEmpty) {
          // Casten der Klassennamen in Strings.
          // Durchlaufen aller Einträge in 'classes' und Extrahieren der Klassennamen.
          for (var item in gettedClasses) {
            Klasse klasse = Klasse(
                klasseId: item['id'],
                klasseName:
                    item['class_name']); // Instanzierung eines Klasse-Objekts
            classes.add(klasse); // Hinzufügen des Klassennamens zur Liste.
          }
          return classes;
        } else {
          // Wenn die Daten unvollständig sind oder das Schlüsselwort 'classes' fehlt,
          // wird eine Warnung ausgegeben und eine leere Liste zurückgegeben.
          print('Data is incomplete or not as expected');
          return [];
        }
      } else {
        // Bei jedem anderen Statuscode als 200 wird eine Fehlermeldung ausgegeben.
        print("Fehler beim Abrufen der Daten: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Fangen von Ausnahmen, die während der HTTP-Anfrage auftreten können,
      // und Ausgabe einer Fehlermeldung.
      print("Exception caught: $e");
      return [];
    }
  }

  /* Retrieves a list of classes from a local JSON file.
   Returns a Future that resolves to a List of [Klasse] objects.
   Throws an error if there is an issue loading the classes from the JSON file.*/
  Future<List<Klasse>> getClassesFromLocalJson(String token, int id) async {
    var jsonString = await rootBundle.loadString(
        'assets/Daten/user_and_passwort_test.json'); // Loads the JSON file from assets
    var jsonResponse = jsonDecode(jsonString); // Decodes the JSON string into a Dart object
    var gettedClasses = jsonResponse['classes'];
    List<Klasse> classes = [];
    if (gettedClasses.isNotEmpty) {
      // Casting the class names to strings.
      // Iterating through all entries in 'classes' and extracting the class names.
      for (var item in gettedClasses) {
        Klasse klasse = Klasse(
            klasseId: item['classe_id'],
            klasseName: item['classe_name']); // Instantiating a Klasse object
        classes.add(klasse); // Adding the class name to the list.
      }
      return classes;
    } else {
      return Future.error('Fehler beim Laden der Klasse aus der JSON-Datei');
    }
  }

  /* Retrieves a list of students for a given class.
   This method sends an HTTP GET request to the server to retrieve a list of students
   for a specific class, identified by the teacher ID and class ID.
   It requires an authentication token to be passed in the `authToken` parameter.
   The method returns a list of `Schueler` objects representing the students.
   If the request is successful and the response contains the expected data,
   the method returns the list of students. Otherwise, it returns an empty list.
   If an error occurs during the HTTP request, the method throws an exception.
  */
  Future<List<Schueler>> getClassStudents(
      String authToken, int lehrerId, int klasseId) async {
    List<Schueler> students = []; // Initialization of an empty list for student names.
    List<dynamic> gettedStudent = [];
    // Creating the complete URL to retrieve the students of a specific teacher's class.
    var url = Uri.parse('$LocalUrlAsIp/teacher/$lehrerId/class/$klasseId/students');
    try {
      // Executing the HTTP GET request with the authentication token in the header.
      var response = await http.get(
        url,
        headers: {
          // Using the previously stored auth token.
          "token": authToken,
        },
      );
      /* Checking if the HTTP status code is 200 OK,
       indicating a successful request. */
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body); // Outputting the received JSON data for debugging purposes.
        // Checking if the JSON data object contains the keyword 'persons'.
        gettedStudent = jsonData['persons']; // Outputting the received JSON data for debugging purposes.
        print('response list: $gettedStudent');
        if (gettedStudent.isNotEmpty) {
          for (var item in gettedStudent) {
            Schueler schueler = Schueler(
                id: 0,
                vorname: '',
                nachname: ''); // Instantiating a Schueler object.
            schueler.id = item['id']; // Extracting the student ID.
            schueler.vorname =
                item['firstname']; // Extracting the student's first name.
            schueler.nachname = item['lastname']; // Extracting the student's last name.
            students.add(schueler); // Adding the student's name to the list.
          }
          for (var item in students) {
            print('Vorname: ${item.vorname} Nachname: ${item.nachname}');
          }
          return students;
        } else {
          // If the data is incomplete or the keyword 'persons' is missing,
          // a warning is printed and an empty list is returned.
          print('Data is incomplete or not as expected');
          return [];
        }
      } else {
        // For any status code other than 200, an error message is returned.
        return Future.error(
            "Fehler beim Abrufen der Daten mit dem status code: ${response.statusCode}\n die Fehler ist: ${response.body}");
      }
    } catch (e) {
      // Catching exceptions that may occur during the HTTP request
      // and printing an error message.
      print("Exception caught: $e");
      return Future.error("Die abfrage konnte nich ausgeführt weil: $e");
    }
  }

  /* Fetches a list of students from a local JSON file.
   Returns a list of [Schueler] objects.
   Throws an error if there is an issue loading the class from the JSON file.
  */
  Future<List<Schueler>> fetchStudentFromLocalJson(String token, int lehrerid, int classId) async {
    List<Schueler> students = [];
    final String jsonSchueler = await rootBundle.loadString('assets/Daten/Schueler12A.json'); // Loads the JSON file from assets
    var jsonResponse = jsonDecode(jsonSchueler); // Decodes the JSON string into a Dart object
    var gettedStudent = jsonResponse['schueler']; // Outputs the received JSON data for debugging purposes.
    if (gettedStudent.isNotEmpty) {
      for (var item in gettedStudent) {
        Schueler schueler = Schueler(
            id: 0,
            vorname: '',
            nachname: ''); // Instantiates a Schueler object.
        schueler.id = item['id']; // Extracts the student ID.
        schueler.vorname =
            item['vorname']; // Extracts the student's first name.
        schueler.nachname = item['nachname']; // Extracts the student's last name.
        students.add(schueler); // Adds the student to the list.
      }
      return students;
    } else {
      return Future.error('Fehler beim Laden der Klasse aus der JSON-Datei'); // Throws an error if there is an issue loading the class from the JSON file.
    }
  }


  Future<SchuelerInfo> getStudentInformation(
      String authToken, int studentId) async {
    // Erstellen der vollständigen URL zum Abrufen der Infomation eines bestimmten Schüler.
    var url = Uri.parse('$LocalUrlAsIp/student/$studentId');
    try {
      // Ausführen der HTTP GET-Anfrage mit Authentifizierungstoken im Header.
      var response = await http.get(
        url,
        headers: {
          // Nutzt das zuvor gespeicherte Auth-Token.
          "token": authToken,
        },
      );
      /* Überprüfung, ob der HTTP-Statuscode 200 OK ist, 
       was auf eine erfolgreiche Anfrage hinweist.*/
      if (response.statusCode == 200) {
        var jsonData = json.decode(response
            .body); // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.

        if (jsonData.isNotEmpty) {
          var adresse = jsonData['address'];
          var kontakt = jsonData['parent'];
          var ags = jsonData['ags'];
          print(ags);
          Adresse studentAdresse = Adresse(
              strasse: adresse['street_name'],
              hausnummer: adresse['house_number'],
              postleitzahl: adresse['postal_code'],
              ort: adresse['location_name']);
          Kontakt erzieher = Kontakt(
              vorname: kontakt['firstname'],
              nachname: kontakt['lastname'],
              telefonnummer: kontakt['phone_number'],
              email: kontakt['email']);
          SchuelerInfo info = SchuelerInfo(
              id: jsonData['person_id'],
              vorname: jsonData['firstname'],
              nachname: jsonData['lastname'],
              adresse: studentAdresse,
              ags: ags,
              kontakt: erzieher); // Instanzierung eines Schueler-Objekts
          print(info.ags);
          return info;
        } else {
          print('es wurde Keine Daten uber diese Schueler gefunden');
          return SchuelerInfo(
              id: 0,
              vorname: '',
              nachname: '',
              adresse: Adresse(
                  strasse: '', hausnummer: '', postleitzahl: 0, ort: ''),
              kontakt: Kontakt(
                  vorname: '', nachname: '', telefonnummer: '', email: ''));
        }
      } else {
        // Bei jedem anderen Statuscode als 200 wird eine Fehlermeldung ausgegeben.
        print("Fehler beim Abrufen der Daten: ${response.statusCode}");
        return Future.error("es wurde ein Fehler beim Abrufen der Daten gefundene: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      // Fangen von Ausnahmen, die während der HTTP-Anfrage auftreten können,
      // und Ausgabe einer Fehlermeldung.
      print("Exception caught: $e");
      return Future.error("s wurde eine Exception während der Abfrage gefangen: $e");
    }
  }

  /* Fetches student information from a local JSON file based on the provided ID.
   The method loads a JSON file from the assets folder and decodes it into a Dart object.
   It then filters the information based on the provided ID and creates instances of the [Adresse], [Kontakt], and [SchuelerInfo] classes. 
   If the filtered information is not empty, the method returns the [SchuelerInfo] object.
   Otherwise, it throws an error indicating a failure in reading the student information from the JSON file. 
   The [id] parameter specifies the ID of the student to fetch information for. Returns a [Future] that completes with the fetched [SchuelerInfo] object.
  */
  Future<SchuelerInfo> fetchStudentInfoFromLocalJson(String token, int id) async {
    final String jsonSchueler = await rootBundle.loadString('assets/Daten/schuelerInfoKlasse12A.json'); // Lädt die JSON-Datei aus Assets
    var jsonResponse = jsonDecode(jsonSchueler); // Decodiert die JSON-String zu einem Dart-Objekt
    var informations = jsonResponse['schueler']; // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
    var filteredIinfo = informations.firstWhere((element) => element['ID'] == id);
    print(filteredIinfo); // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
    if (filteredIinfo.isNotEmpty) { // Ausgabe der empfangenen JSON-Daten für Debug-Zwecke.
          var adresse = filteredIinfo['Adresse'];
          var kontakt = filteredIinfo['Kontakt'];
          var ags = filteredIinfo['AGs'];
          print(ags);
          Adresse studentAdresse = Adresse(
              strasse: adresse['Straße'],
              hausnummer: adresse['Hausnummer'],
              postleitzahl: adresse['Postleitzahl'],
              ort: 'Bremen'); // 'Ort' ist in der JSON-Datei nicht vorhanden, daher wird ein fester Wert verwendet.
          Kontakt erzieher = Kontakt(
              vorname: kontakt['Vorname'],
              nachname: kontakt['Nachname'],
              telefonnummer: kontakt['Telefonnummer'],
              email: kontakt['E-Mail']);
          SchuelerInfo info = SchuelerInfo(
              id: filteredIinfo['ID'],
              vorname: filteredIinfo['Vorname'],
              nachname: filteredIinfo['Nachname'],
              adresse: studentAdresse,
              ags: ags,
              kontakt: erzieher); // Instanzierung eines Schueler-Objekts
          print(info.ags);
          return info;
    }
    else {
      return Future.error('Fehler beim Lesen der Schueler Informationen aus der JSON-Datei');
    }
  }


// Methode zum Senden des Bildes
  Future<Map<String, dynamic>> sendImage(
      String authToken, List<int> imageBytes) async {
    // Konvertiert Byte-Daten zu einem Base64-String

    String base64Image = base64Encode(imageBytes);
    //print(base64Image);
    var toSend = jsonEncode({'image': base64Image});

    try {
      var response = await http
          .post(
            Uri.parse('$LocalUrlAsIp/image'), // URL für das Senden des Bildes
            headers: {
              'Content-Type': 'application/json',
              'token': authToken,
            },
            body: toSend,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        print(
            'Fehler beim Senden des Bildes: ${response.statusCode} ${response.body}');
        return {};
      }
    } catch (e) {
      print('Exception caught while sending the image: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> testADOverlay(String token) async{
    try {
      var response = await http
          .post(
            Uri.parse('$LocalUrlAsIp/image/testAG'), // URL für das Senden des Bildes
            headers: {
              'Content-Type': 'application/json',
              'token': token,
            },
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        Future.error(
            'Fehler beim Senden des Bildes: ${response.statusCode} ${response.body}');
        return {};
      }
    } catch (e) {
      Future.error('Exception caught while sending the image: $e');
      return {};
    }
  }

}
