import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/BlattView/InitialOverlay.dart';
import 'package:lectorai_frontend/seiten/BlattView/SelectableOverlayList.dart';

class OverlayList extends StatefulWidget {
  final dynamic items; //Die Elemente, die angezeigt oder bearbeitet werden sollen.
  final String boxname; //Ein String, der angibt, welche Art von Daten angezeigt wird (z. B. 'addresse', 'erzieher', 'schueler', 'ag')
  final ValueChanged<Map<String, dynamic>> onItemSelected; //Ein Callback, der aufgerufen wird, wenn der Benutzer die Einträge bestätigt hat.
  final bool isDemoModus; //Ein optionales Flag, das den Demo-Modus aktiviert

  OverlayList({
    required this.items,
    required this.onItemSelected,
    required this.boxname,
    this.isDemoModus = false,
  });

  @override
  //Erzeugt den Zustand OverlayListState für diese StatefulWidget-Klasse.
  _OverlayListState createState() => _OverlayListState();
}

class _OverlayListState extends State<OverlayList> {
  bool _isContainerVisible = true; //Steuert die Sichtbarkeit des Containers.
  bool _showInitialOverlay = true; //Steuert die Anzeige des initialen Overlays.
  bool _showSelectableOverlay = false; //Steuert die Anzeige des auswählbaren Overlays.
  final Map<String, TextEditingController> _controllers = {}; //Ein Map, das TextEditingController für die verschiedenen Eingabefelder enthält.

  @override
  //Gibt die TextEditingController frei, wenn sie nicht mehr benötigt werden.
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  // Initialisiert die TextEditingController basierend auf den übergebenen items und dem boxname.
  void initState() {
    super.initState();
    // Initialize controllers based on the boxname
    if (widget.items != null && widget.items.isNotEmpty) {
  if (widget.boxname == 'addresse') {
    var selectedItem = widget.items[0];
    _controllers['street'] = TextEditingController(text: selectedItem['street_name']);
    _controllers['houseNumber'] = TextEditingController(text: selectedItem['house_number']);
    _controllers['postalCode'] = TextEditingController(text: selectedItem['postal_code'].toString());
    _controllers['city'] = TextEditingController(text: 'Bremen');
  } else if (widget.boxname == 'erzieher') {
    var selectedItem = widget.items[0];
    _controllers['erzieherLastname'] = TextEditingController(text: selectedItem['parent']['firstname']);
    _controllers['erzieherFirstname'] = TextEditingController(text: selectedItem['parent']['lastname']);
    _controllers['phoneNumber'] = TextEditingController(text: selectedItem['parent']['phone_number']);
    _controllers['email'] = TextEditingController(text: selectedItem['parent']['email']);
  } else if (widget.boxname == 'schueler') {
    var selectedItem = widget.items[0];
    _controllers['schuelerLastname'] = TextEditingController(text: selectedItem['firstname']);
    _controllers['schuelerFirstname'] = TextEditingController(text: selectedItem['lastname']);
    _controllers['schoolClass'] = TextEditingController(text: selectedItem['school_class']);
  }
}
}

  //Erzeugt den Text, der im Overlay angezeigt wird, basierend auf dem boxname.
  Widget _buildOverlayText(String boxname) {
    String text;
    switch (boxname) {
      case 'schueler':
        text = 'Durch Analyse könnten mehrere Schüler mit diesem Namen gefunden werden.\n Tragen Sie die richtigen Schuelerdaten ein.';
        break;
      case 'erzieher':
        text = 'Nach Analyse wurde mehrere Erzieher gefunden.\n Tragen Sie die richtigen Erzieherberechtigteninformationen ein.';
        break;
      case 'addresse':
        text = 'Durch KI-Analyse wurden mehrere Adressen gefunden.\n Tragen Sie die richtige Adresse ein.';
        break;
      default:
        text = 'Für diese Schule wurden folgende AGs gefunden.\n Tragen die richtige AGs ein.';
    }

    return FittedBox(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

 //Baut die Eingabefelder für Adressdaten.
  Widget _buildAddressContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Straße', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['street'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Hausnummer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['houseNumber'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Postleitzahl', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['postalCode'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Stadt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['city'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

//Baut die Eingabefelder für Schülerdaten
Widget _buildSchuelerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nachname', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['schuelerLastname'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Vorname', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['schuelerFirstname'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Klasse', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['schoolClass'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

   //Baut die Eingabefelder für Erzieherdaten.
    Widget _buildErzieherContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nachname', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['erzieherLastname'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Vorname', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['erzieherFirstname'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Telefonnummer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['phoneNumber'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        TextField(
          controller: _controllers['email'],
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

//Baut die Eingabefelder für die AG-Wahlen.
Widget _buildListTextContent(var data, int index) {
  final String listText;
  int pointer = index + 1; // Adjusted pointer to match your expected logic

  // Überprüfen Sie, ob der Index innerhalb des gültigen Bereichs liegt
  if (pointer < 1 || pointer > 3) {
    return SizedBox.shrink(); // Wenn der Index ungültig ist, einfach ein leeres Widget zurückgeben
  }

  var ag = data['ag_$pointer']; // Daten für die entsprechende AG-Wahl laden

  if (ag != null && ag.isNotEmpty) {
    listText = ag.map((agItem) => '${agItem['name']}').join(', ');
  } else {
    listText = 'Keine AGs gefunden';
  }

  // Wenn keine AGs gefunden wurden, entfernen wir den entsprechenden Controller
  if (listText == 'Keine AGs gefunden') {
    if (_controllers.containsKey('name$pointer')) {
      _controllers.remove('name$pointer');
    }
    return SizedBox.shrink(); // Kein Widget zurückgeben, wenn keine AGs vorhanden sind
  }

  // Textcontroller für die aktuelle AG-Wahl initialisieren, falls nicht vorhanden
  if (!_controllers.containsKey('name$pointer')) {
    _controllers['name$pointer'] = TextEditingController();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('AG Wahl $pointer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      TextField(
        controller: _controllers['name$pointer'],
        decoration: InputDecoration(
          hintText: listText,
          contentPadding: EdgeInsets.all(8.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          // Handle text field value change
        },
      ),
    ],
  );
}


  //Sammelt die eingegebenen Daten und ruft den Callback onItemSelected auf.
  void _confirmSelection() {
    
    String allText = '';
    List<int> allIds = [];

    if (widget.boxname == 'addresse') {
      var selectedItem = widget.items[0];
      allText += '${_controllers['street']?.text ?? ''}-${_controllers['houseNumber']?.text ?? ''}\n ${_controllers['postalCode']?.text ?? ''}\n ${_controllers['city']?.text ?? ''}';
      if (selectedItem['id'] != null) { // Nullprüfung hinzugefügt
      allIds.add(selectedItem['id']);
    }
      widget.onItemSelected({
        'text': allText.trim(),
        'id': allIds.isNotEmpty ? allIds.first : null,
      });
    } else if (widget.boxname == 'schueler') {
      var selectedItem = widget.items[0];
      allText += '${_controllers['schuelerLastname']?.text ?? ''}\n${_controllers['schuelerFirstname']?.text ?? ''}\n${_controllers['schoolClass']?.text ?? ''}';
      allIds.add(selectedItem['id']);
      widget.onItemSelected({
        'text': allText.trim(),
        'id': allIds.isNotEmpty ? allIds.first : null,
      });
    } else if (widget.boxname == 'erzieher') {
      var selectedItem = widget.items[0];
      allText += '${_controllers['erzieherLastname']?.text ?? ''}\n${_controllers['erzieherFirstname']?.text ?? ''}\n ${_controllers['phoneNumber']?.text ?? ''}\n ${_controllers['email']?.text ?? ''}';
      allIds.add(selectedItem['parent']['id']);
      widget.onItemSelected({
        'text': allText.trim(),
        'id': allIds.isNotEmpty ? allIds.first : null,
      });
    } else {
      _controllers.forEach((key, controller) {
          int agPointer = int.parse(key.substring(4));
          var selectedItemAG = widget.items['ag_$agPointer'];
          if (selectedItemAG != null && selectedItemAG.length > 0) {
            allText += '${controller.text}\n';
            for (var ag in selectedItemAG) {
              allIds.add(ag['id']);
            }
          }
      });
      widget.onItemSelected({
        'text': allText.trim(),
        'id': allIds,
      });
    }
  }

  @override
  //Baut das UI basierend auf dem aktuellen Zustand der Variablen _isContainerVisible, _showInitialOverlay und _showSelectableOverlay.
  Widget build(BuildContext context) {
    return Center(
      child: _isContainerVisible
          ? Stack(
              children: [
                _showInitialOverlay //InitialOverlay Wird beim ersten Anzeigen des Widgets angezeigt
                    ? InitialOverlay(
                      //Bei Auswahl von "Eintragen" wird der InitialOverlay geschlossen und der Hauptinhalt angezeigt.
                        onEintragenPressed: () {
                          setState(() {
                            _showInitialOverlay = false;
                          });
                        },
                        //Bei Auswahl von "Auswählen" wird der InitialOverlay geschlossen und das auswählbare Overlay wird angezeigt.
                        onAuswaehlenPressed: () {
                          setState(() {
                            _showInitialOverlay = false;
                            _isContainerVisible = false;
                            _showSelectableOverlay = true;
                          });
                        },
                      )
                    : Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xff3d7c88),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //Zeigt die Eingabefelder basierend auf dem boxname an (Adresse, Schüler, Erzieher oder AGs).
                            children: [
                              _buildOverlayText(widget.boxname),
                              SizedBox(height: 8),
                              if (widget.boxname == 'addresse')
                                _buildAddressContent()
                              else if (widget.boxname == 'schueler')
                                _buildSchuelerContent()
                              else if (widget.boxname == 'erzieher')
                                _buildErzieherContent()
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: widget.items.length -1,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        _buildListTextContent(widget.items, index),
                                        SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                              ElevatedButton(
                                onPressed: _confirmSelection,
                                child: Text('Bestätigen'),
                              ),
                            ],
                          ),
                        ),
                      ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isContainerVisible = false;
                      });
                    },
                  ),
                ),
              ],
            )
          : _showSelectableOverlay //Wenn _showSelectableOverlay auf true gesetzt ist, wird eine Seite zum Auswählen von Elementen angezeigt.
              ? Navigator(
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => SelectableOverlayList(
                      items: widget.items,
                      onItemSelected: widget.onItemSelected,
                      boxname: widget.boxname,
                    ),
                  ),
                )
              : SizedBox.shrink(),
    );
  }
}
