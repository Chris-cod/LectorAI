import 'package:flutter/material.dart';
import 'package:lectorai_frontend/seiten/BlattView/InitialOverlay.dart';
import 'package:lectorai_frontend/seiten/BlattView/SelectableOverlayList.dart';

class OverlayList extends StatefulWidget {
  final dynamic items;
  final String boxname;
  final ValueChanged<Map<String, dynamic>> onItemSelected;
  final bool isDemoModus;

  OverlayList({
    required this.items,
    required this.onItemSelected,
    required this.boxname,
    this.isDemoModus = false,
  });

  @override
  _OverlayListState createState() => _OverlayListState();
}

class _OverlayListState extends State<OverlayList> {
  bool _isContainerVisible = true;
  bool _showInitialOverlay = true; // Show initial overlay first
  bool _showSelectableOverlay = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if(!widget.isDemoModus) {
      _isContainerVisible = true;
      _showInitialOverlay = false;
      _showSelectableOverlay = true;
    } else {
      _isContainerVisible = true;
    }
    // Initialize controllers based on the boxname
    if (widget.boxname == 'addresse' && widget.items.isNotEmpty) {
      var selectedItem = widget.items[0];
      _controllers['street'] = TextEditingController(text: selectedItem['street_name']['value']);
      _controllers['houseNumber'] = TextEditingController(text: selectedItem['house_number']);
      _controllers['postalCode'] = TextEditingController(text: selectedItem['location']['postal_code'].toString());
      _controllers['city'] = TextEditingController(text: selectedItem['location']['location_name']);
    } else if (widget.boxname == 'erzieher' || widget.boxname == 'schueler') {
      for (int i = 1; i < widget.items.length; i++) {
        var item = widget.items[i];
        _controllers['name$i'] = TextEditingController(text: '${item['firstname']['value']} ${item['lastname']['value']}');
        if (widget.boxname == 'erzieher') {
          _controllers['phoneNumber$i'] = TextEditingController(text: item['parent']['phone_number']['value']);
          _controllers['email$i'] = TextEditingController(text: item['parent']['email']['value']);
        } else if (widget.boxname == 'schueler') {
          _controllers['schoolClass$i'] = TextEditingController(text: item['school_class']['value']);
        }
      }
    }
  }

  Widget _buildOverlayText(String boxname) {
    String text;
    switch (boxname) {
      case 'schueler':
        text =
            'Durch Analyse könnten mehrere Schüler mit diesem Namen gefunden werden.\n Tragen Sie die richtigen Schuelerdaten ein.';
        break;
      case 'erzieher':
        text =
            'Nach Analyse wurde mehrere Erzieher gefunden.\n Tragen Sie die richtigen Erzieherberechtigteninformationen ein.';
        break;
      case 'addresse':
        text =
            'Durch KI-Analyse wurden mehrere Adressen gefunden.\n Tragen Sie die richtige Adresse ein.';
        break;
      default:
        text =
            'Für diese Schule wurden folgende AGs gefunden.\n Tragen die richtige AGs ein.';
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

  Widget _buildListTextContent(var data, String boxname, int index) {
    final String label;
    final String listText;
    int pointer = index + 1;

    switch (boxname) {
      case 'schueler':
        label = 'Schüler';
        listText =
            '${data[pointer]['firstname']['value']} ${data[pointer]['lastname']['value']}, ${data[pointer]['school_class']['value']}';
        break;
      case 'erzieher':
        label = 'Erzieher';
        listText =
            '${data[pointer]['parent']['firstname']['value']} ${data[pointer]['parent']['lastname']['value']}, ${data[pointer]['parent']['phone_number']['value']}, ${data[pointer]['parent']['email']['value']}';
        break;
      default:
        label = 'AG Wahl ${index + 1}';
        var ag;
        switch (pointer) {
          case 1:
            ag = data['ag_1'];
            break;
          case 2:
            ag = data['ag_2'];
            break;
          case 3:
            ag = data['ag_3'];
            break;
          default:
            ag = null;
        }

        if (ag != null && ag.isNotEmpty) {
          listText = ag.map((agItem) => '${agItem['ag_name']['value']}').join(', ');
        } else {
          listText = 'Keine AGs gefunden';
        }
    }
    if (listText == 'Keine AGs gefunden') {
    // Wenn keine AGs gefunden wurden, entfernen wir den Controller
    if (_controllers.containsKey('name$pointer')) {
      _controllers.remove('name$pointer');
    }
    return SizedBox.shrink(); // Kein Widget zurückgeben, wenn keine AGs vorhanden sind
   }
    if (!_controllers.containsKey('name$pointer')) {
      _controllers['name$pointer'] = TextEditingController();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
        if (boxname == 'erzieher')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text('Telefonnummer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              TextField(
                controller: _controllers['phoneNumber$pointer'],
                decoration: InputDecoration(
                  hintText: 'Telefonnummer',
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
                controller: _controllers['email$pointer'],
                decoration: InputDecoration(
                  hintText: 'Email',
                  contentPadding: EdgeInsets.all(8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        if (boxname == 'schueler')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text('Klasse', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              TextField(
                controller: _controllers['schoolClass$pointer'],
                decoration: InputDecoration(
                  hintText: 'Klasse',
                  contentPadding: EdgeInsets.all(8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _confirmSelection() {
    Map<String, dynamic> result = {};
    String allText = '';
    List<int> allIds = [];

    if (widget.boxname == 'addresse') {
      var selectedItem = widget.items[0];
      allText += '${_controllers['street']!.text} ${_controllers['houseNumber']!.text}\n ${_controllers['postalCode']!.text}\n ${_controllers['city']!.text}';
      allIds.add(selectedItem['id']);
      widget.onItemSelected({
        'text': allText.trim(),
        'id': allIds.isNotEmpty ? allIds.first : null,
      });
    } else {
      _controllers.forEach((key, controller) {
        var selectedItem = widget.items[int.parse(key.substring(4))]; // Extract the index from controller key
        if (widget.boxname == 'schueler') {
          allText += '${controller.text}\n';
          allIds.add(selectedItem['id']);
        } else if (widget.boxname == 'erzieher') {
          allText += '${controller.text}\n';
          allIds.add(selectedItem['parent']['id']);
        } else {
          int agPointer = int.parse(key.substring(4));
          var selectedItemAG = widget.items['ag_$agPointer'];
          if (selectedItemAG != null && selectedItemAG.length > 0) {
            allText += '${controller.text}\n';
            for (var ag in selectedItemAG) {
              allIds.add(ag['id']);
            }
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
Widget build(BuildContext context) {
  return Center(
    child: _isContainerVisible
        ? Stack(
            children: [
              _showInitialOverlay
                  ? InitialOverlay(
                      onEintragenPressed: () {
                        setState(() {
                          _showInitialOverlay = false;
                        });
                      },
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
                          children: [
                            _buildOverlayText(widget.boxname),
                            SizedBox(height: 8),
                            if (widget.boxname == 'addresse')
                              _buildAddressContent()
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.items.length - 1,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      _buildListTextContent(widget.items, widget.boxname, index),
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
        : _showSelectableOverlay
            ? Navigator(
                // Hier Navigator statt Navigator.push, um den Kontext nicht zu verlieren
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