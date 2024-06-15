import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectorai_frontend/models/klasse.dart';
import 'package:lectorai_frontend/models/schueler.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';
import 'package:lectorai_frontend/seiten/Klasse/schuler_details.dart';
import 'package:lectorai_frontend/services/repository.dart';

class Schuelern extends StatefulWidget {
  final int klasseId;
  final int lehrerId;
  final String token;
  final String klasseName;
  final bool demoModus;
  const Schuelern({super.key, required this.klasseId, required this.lehrerId, required this.token, required this.klasseName, required this.demoModus});

  @override
  SchulernListStatr createState() => SchulernListStatr();
}

class SchulernListStatr extends State<Schuelern>{ 
  List<Schueler> alleSchueler = [];

  List<Schueler> filteredSchueler = [];

  Repository repository = Repository();

  static bool isLoading = false;

  /// Initializes the state of the widget.
  /// This method is called when the widget is inserted into the tree.
  /// It calls the [readJsonFile] function during the initialization process.
  @override
  void initState() {
    super.initState();
    initList(); // Aufruf der Funktion im initState
  }

  void initList() async{
    List<Schueler> allStudent;
        if(widget.demoModus){
          allStudent = await repository.fetchStudentFromLocalJson(widget.token, widget.lehrerId, widget.klasseId);
        }
        else{
          allStudent = await repository.getClassStudents(widget.token, widget.lehrerId, widget.klasseId);
        }
    String allStudentString = allStudent.toString();
    print("alle schueler von backend: $allStudentString");
    if(allStudent.isNotEmpty){
        setState(() {
        alleSchueler = allStudent.toList();
        alleSchueler.sort((a, b) => a.nachname.compareTo(b.nachname));
        filteredSchueler = alleSchueler;
      });
    }
    else{
      isLoading = true;
    }
  }


  /// Runs the filter based on the provided search keyword.
  ///
  /// If the [searchKeyword] is empty, the [filteredSchueler] list will be set to the [alleSchueler] list.
  /// Otherwise, the [filteredSchueler] list will be set to a filtered version of the [alleSchueler] list,
  /// where the [vorname] or [nachname] of each [Schueler] object contains the [searchKeyword] (case-insensitive).
  /// Finally, it refreshes the UI by calling [setState] and updating the [filteredSchueler] list.
  void _runFilter(String searchKeyword, String filterType) {
    List<Schueler> results = [];

    if (searchKeyword.isEmpty) {
      results = alleSchueler;
    } else {
      if (filterType == 'vorname') {
        results = alleSchueler.where((element) =>
            element.vorname.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
      } else if (filterType == 'nachname') {
        results = alleSchueler.where((element) =>
            element.nachname.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
      }
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
          title: Text(
            'Schüler der Klasse ${widget.klasseName}',
      //      style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        //  backgroundColor: const Color(0xff48CAE4),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              height: 10,
              child: Image.asset(
                'assets/Bilder/_.png',
      //          color: Colors.black,
                scale: 1.0,
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
        //  color: const Color(0xFF0077B6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 35,
                      child: TextField(
                        onChanged: (value) => _runFilter(value, 'nachname'),
                        decoration: InputDecoration(
                          fillColor: Color.fromARGB(255, 15, 15, 15),
                          labelText: 'Nachname suchen',
      //                    labelStyle: const TextStyle(color: Colors.black, fontSize: 12.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
      //                    prefixIcon: Icon(Icons.search, color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 35,
                      child: TextField(
                        onChanged: (value) => _runFilter(value, 'vorname'),
                        decoration: InputDecoration(
       //                   fillColor: Color.fromARGB(255, 15, 15, 15),
                          labelText: 'Vorname suchen',
      //                    labelStyle: const TextStyle(color: Colors.black, fontSize: 12.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(35.0)),
   //                       prefixIcon: Icon(Icons.search, color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSchueler.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchuelerDetails(
                                      token: widget.token,
                                      schuelerId: filteredSchueler[index].id,
                                      demoModus: widget.demoModus,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
//                                  color: const Color(0xff90E0EF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  filteredSchueler[index].nachname,
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SchuelerDetails(
                                      token: widget.token,
                                      schuelerId: filteredSchueler[index].id,
                                      demoModus: widget.demoModus,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
  //                                color: const Color(0xff90E0EF),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  filteredSchueler[index].vorname,
                                  style: const TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
