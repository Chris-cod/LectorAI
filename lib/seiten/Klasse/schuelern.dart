import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectorai_frontend/models/adresse.dart';
import 'package:lectorai_frontend/models/kontakt.dart';
import 'package:lectorai_frontend/models/schueler.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuler_details.dart';

class Schuelern extends StatefulWidget {
  const Schuelern({super.key});

  @override
  SchulernListStatr createState() => SchulernListStatr();
}

class SchulernListStatr extends State<Schuelern>{ 
  List<Schueler> alleSchueler = List.empty();

  List<Schueler> filteredSchueler = List.empty();

  /// Initializes the state of the widget.
  /// This method is called when the widget is inserted into the tree.
  /// It calls the [readJsonFile] function during the initialization process.
  @override
  void initState() {
    super.initState();
    initList(); // Aufruf der Funktion im initState
  }


  /// Reads a JSON file and updates the state with the parsed data.
  Future<List<dynamic>> readJsonFile(String fileName) async {

    try {
      final String response = await rootBundle.loadString('assets/Daten/$fileName.json');
      final schulerData = await json.decode(response);

      var slist = schulerData["schueler"] as List<dynamic>;
      
      return slist;
    } catch (e) {
      print('Fehler beim Laden der Schülerdaten: $e');
      return List.empty();
    }

  }


  // initList() async {
  //   final jsonlist = await readJsonFile('Schueler12A');
  //   alleSchueler = jsonlist.map((json) => Schueler.fromJson(json)).toList();
  //   print(alleSchueler.first.vorname);
  //   filteredSchueler = alleSchueler;
  // }

  initList() {
    readJsonFile('Schueler12A').then((jsonList) {
      setState(() {
        alleSchueler = jsonList.map((json) => Schueler.fromJson(json)).toList();
        filteredSchueler = alleSchueler;
      });
    });
  }

  


//  SchuelerInfo getSchulerInfo(String name) {
//     SchuelerInfo schuelerInfo = SchuelerInfo(adresse: Adresse(), kontakt: Kontakt());
//     readJsonFile('schuelerInfoKlasse12A').then((jsonList) {
//       var element = jsonList.where((element) => element.contains(name));
//       if (element != null) {
//         schuelerInfo = element;
//       }
//     });
//     return schuelerInfo;
// }

  /// Runs the filter based on the provided search keyword.
  ///
  /// If the [searchKeyword] is empty, the [filteredSchueler] list will be set to the [alleSchueler] list.
  /// Otherwise, the [filteredSchueler] list will be set to a filtered version of the [alleSchueler] list,
  /// where the [vorname] or [nachname] of each [Schueler] object contains the [searchKeyword] (case-insensitive).
  /// Finally, it refreshes the UI by calling [setState] and updating the [filteredSchueler] list.
  void _runFilter(String searchKeyword) {
    List<Schueler> results = [];

    if (searchKeyword.isEmpty) {
      results = alleSchueler;
    } else {
      results = alleSchueler.where((element) =>
          element.vorname.toLowerCase().contains(searchKeyword.toLowerCase()) ||
          element.nachname.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
    }

    // refresh the UI
    setState(() {
      filteredSchueler = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schüler der Klasse 12a', style: TextStyle(color: Colors.black), textAlign: TextAlign.center,),
          backgroundColor: const Color(0xff48CAE4),
          leading:GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              height: 10,
              child: Image.asset('assets/Bilder/angle-left.png', color: Colors.black, scale: 1.0,),
            )
            
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          color: const Color(0xFF0077B6),
          child: Column(
            children: [
              SizedBox(
                width: 210,
                height: 35,
                child: TextField(
                  onChanged: (value) => _runFilter(value),
                  decoration: InputDecoration(
                    fillColor: Color.fromARGB(255, 15, 15, 15),
                    labelText: 'Suchen',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
                    prefixIcon:  Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset('assets/Bilder/search.png', color: Colors.black, scale: 1.0,),
                    )
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSchueler.length,
                  itemBuilder: (context, index) {
                    final sortedList = filteredSchueler..sort((a, b) => a.vorname.compareTo(b.vorname));
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                      color: const Color(0xff90E0EF),
                      child: ListTile(
                        // leading: 
                        // CircleAvatar(
                        //   backgroundColor: Colors.blue,
                        //   child: Text(
                        //     (index + 1).toString(),
                        //     style: TextStyle(color: Colors.white),
                        //   ),
                        // ),
                        title: Text(sortedList[index].vorname + ' ' + sortedList[index].nachname, style: const TextStyle(fontSize: 25.0)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchuelerDetails(schuelerId: sortedList[index].id),
                            ),
                          );
                          print('Schüler ${sortedList[index].vorname} ${sortedList[index].nachname} wurde ausgewählt');
                        },
                      )
                    );
                  }
                    
                ),
              ),
            ],
        ),
        )
      ),
    );
  }

 
}
