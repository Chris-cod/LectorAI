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

class SchulernListStatr extends State<Schuelern> {
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

    setState(() {
      filteredSchueler = results;
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
        buildSearchField(theme, 'Nachname...', 'nachname'),
        const SizedBox(width: 10),
        buildSearchField(theme, 'Vorname...', 'vorname'),
      ],
    );
  }

  Widget buildSearchField(ThemeData theme, String labelText, String filterType) {
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
            labelText: labelText,
            labelStyle: TextStyle(
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(35.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
