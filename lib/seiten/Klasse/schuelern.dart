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
  SchulernListState createState() => SchulernListState();
}

class SchulernListState extends State<Schuelern> {
  List<Schueler> alleSchueler = [];
  List<Schueler> filteredSchueler = [];
  Repository repository = Repository();
  static bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initList();
  }

  void initList() async {
    List<Schueler> allStudent = widget.demoModus
        ? await repository.fetchStudentFromLocalJson(widget.token, widget.lehrerId, widget.klasseId)
        : await repository.getClassStudents(widget.token, widget.lehrerId, widget.klasseId);

    print("Alle Schüler von Backend: ${allStudent.toString()}");
    setState(() {
      alleSchueler = allStudent.toList()..sort((a, b) => a.nachname.compareTo(b.nachname));
      filteredSchueler = alleSchueler;
      isLoading = alleSchueler.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Schüler der Klasse ${widget.klasseName}', textAlign: TextAlign.center),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              buildSearchRow(theme),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSchueler.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.person, color: theme.iconTheme.color), // Adjust icon color based on theme
                        onTap: () {
                          _navigateToDetails(context, filteredSchueler[index].id);
                        },
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(filteredSchueler[index].nachname),
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Colors.grey,
                              margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            ),
                            Expanded(
                              child: Text(filteredSchueler[index].vorname),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward, color: theme.iconTheme.color), // Adjust icon color based on theme
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

  Widget buildSearchRow(ThemeData theme) {
    return Row(
      children: [
        buildSearchField(theme, 'Nachname...', 'nachname', Icons.search),
        const SizedBox(width: 10),
        buildSearchField(theme, 'Vorname...', 'vorname', Icons.search),
      ],
    );
  }
  void _runFilter(String searchKeyword, String filterType) {
    List<Schueler> results = [];

    if (searchKeyword.isEmpty) {
      results = alleSchueler;
    } else {
      if (filterType == 'vorname') {
        results = alleSchueler.where((schueler) =>
            schueler.vorname.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
      } else if (filterType == 'nachname') {
        results = alleSchueler.where((schueler) =>
            schueler.nachname.toLowerCase().contains(searchKeyword.toLowerCase())).toList();
      }
    }

    setState(() {
      filteredSchueler = results;
    });
  }


  Widget buildSearchField(ThemeData theme, String labelText, String filterType, IconData icon) {
    return Expanded(
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[300],
          borderRadius: BorderRadius.circular(35.0),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) => _runFilter(value, filterType),
          decoration: InputDecoration(
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(icon, color: theme.iconTheme.color), // Adjust icon color based on theme
            ),
            labelText: labelText,
            labelStyle: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(35.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
          style: TextStyle(fontSize: 12.0),
        ),
      ),
    );
  }


  void _navigateToDetails(BuildContext context, int schuelerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchuelerDetails(
          token: widget.token,
          schuelerId: schuelerId,
          demoModus: widget.demoModus,
        ),
      ),
    );
  }
}
