import 'package:flutter/material.dart';

class SelectableOverlayList extends StatefulWidget {
  var items;
  final ValueChanged<Map<String, dynamic>> onItemSelected;
  final String boxname; // das ist die 

  SelectableOverlayList({
    required this.items,
    required this.onItemSelected,
    required this.boxname,
  });

  @override
  _SelectableOverlayListState createState() => _SelectableOverlayListState();
}

class _SelectableOverlayListState extends State<SelectableOverlayList> {
  bool _isContainerVisible = true;
  String? selectedStudent;
  String? selectedParent;
  String? selectedAdresse;
  String? selectedAG1;
  String? selectedAG2;
  String? selectedAG3;

  List<String> studentItems = [];  //list von Schueler
  List<String> parentItems = [];  //list von Erzieherberechtigten
  List<String> adresseItems = []; //list von Adressen
  List<String> ag1 = []; //list von AG1
  List<String> ag2 = [];  //list von AG2
  List<String> ag3 = [];    //list von AG3

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

// hier wird die Liste von Schueler, Erzieher, Adressen und AGs initialisiert
  void _initializeItems() { 
    if(widget.boxname == 'schueler') {
      for (var item in widget.items) {
        studentItems.add('${item['lastname'] ?? 'Kein vorname'} | ${item['firstname'] ?? 'Kein Nachname'} |'
        ' ${item['school_class'] ?? '0X'}');
      }
    } else if(widget.boxname == 'erzieher') {
      for (var item in widget.items) {
        parentItems.add('${item['parent']['lastname'] ?? 'Kein Erzieher Name'} | ${item['parent']['firstname'] ?? 'kein Vorname'}\n'
        '${item['parent']['phone_number'] ?? 'kein Telefonnummer'} | ${item['parent']['email'] ?? 'keine Email'}');
      }
    } else if(widget.boxname == 'addresse') {
      for (var item in widget.items) {
        adresseItems.add('${item['street_name'] ?? 'keine Straße'} | ${item['house_number'] ?? '0X'}\n'
        '${item['postal_code'] ?? '00000'} | Bremen');
      }
    } else {
      if (widget.items['ag_1'] != null) {
        for (var ag in widget.items['ag_1']) {
          ag1.add(ag['name']);
        }
      }
      else{
        ag1.add('Keine AG1 vorhanden');
      }

      if (widget.items['ag_2'] != null) {
        for (var ag in widget.items['ag_2']) {
          ag2.add(ag['name']);
        }
      }
      else{
        ag2.add('Keine AG2 vorhanden');
      }

      if (widget.items['ag_3'] != null) {
        for (var ag in widget.items['ag_3']) {
          ag3.add(ag['name']);
        }
      }
      else{
        ag3.add('Keine AG3 vorhanden');
      }
    }
  }

  
  // hier wird der default Wert initialisiert, die in der Dropdown-Liste angezeigt wird
  void initDefaultValues() {
    if (widget.boxname == 'schueler') {
      selectedStudent = studentItems[0];
    } else if (widget.boxname == 'erzieher') {
      selectedParent = parentItems[0];
    } else if (widget.boxname == 'addresse') {
      selectedAdresse = adresseItems[0];
    } else {
      selectedAG1 = ag1[0];
      selectedAG2 = ag2[0];
      selectedAG3 = ag3[0];
    }
  }

  //hier wird die Dropdown-Liste und Text zusammen aufgebaut und angezeigt 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: _isContainerVisible 
          ? Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xff3d7c88),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // je nach boxname wird der Text angezeigt
                      _buildOverlayText(widget.boxname),
                      const SizedBox(height: 10),
                      // je nach boxname wird die Dropdown-Liste aufgebaut
                      buildDropdown(widget.boxname),
                    ],
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
                // Bestätigen Button zum Bestätigen der Auswahl
                Positioned(
                  bottom: 10,
                  right: 70,
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('Bestätigen'),
                  ),
                ),
              ],
            )
            : SizedBox.shrink(),
      )
    );
  }

 // hier wird der Text für die Overlay-Box aufgebaut
  Widget _buildOverlayText(String boxname) {
    final String text;
    if (boxname == 'schueler') {
      text = 'Durch Analyse könnten mehrere Schüler mit diesem Namen gefunden werden.\nWählen Sie aus der Liste den richtigen Namen.';
    } else if (boxname == 'erzieher') {
      text = 'Nach Analyse wurden mehrere Erzieher gefunden.\nWählen Sie aus der Liste den richtigen Erziehungsberechtigten.';
    } else if (boxname == 'addresse') {
      text = 'Durch KI-Analyse wurden mehrere Adressen gefunden.\nWählen Sie aus der Liste die richtige Adresse.';
    } else {
      text = 'Für diese Schüler wurden folgende AGs gefunden.\nWählen Sie aus der Liste die richtigen AGs.';
    }

    return FittedBox(
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(255, 29, 13, 13),
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // hier wird die Dropdown-Liste je nach boxname aufgebaut
  Widget buildDropdown(String boxname) {
    switch (boxname) {
      case 'schueler':
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Text('Schüler Auswählen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedStudent,
                style: const TextStyle(fontSize: 12, color: Colors.black),
                onChanged: (newValue) {
                  setState(() {
                    selectedStudent = newValue;
                  });
                },
                items: studentItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case 'erzieher':
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Text('Erzieher Auswälen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedParent,
                style: const TextStyle(fontSize: 11, color: Colors.black),
                onChanged: (newValue) {
                  setState(() {
                    selectedParent = newValue;
                  });
                },
                items: parentItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case 'addresse':
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Text('Adresse', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedAdresse,
                style: const TextStyle(fontSize: 11, color: Colors.black),
                onChanged: (newValue) {
                  setState(() {
                    selectedAdresse = newValue;
                  });
                },
                items: adresseItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      case 'ag':
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('AG 1: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedAG1,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG1 = newValue ?? '';
                      });
                    },
                    items: ag1.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('AG 2: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedAG2,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG2 = newValue ?? '';
                      });
                    },
                    items: ag2.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('AG 3: ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedAG3,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG3 = newValue ?? '';
                      });
                    },
                    items: ag3.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }


  // This method is called when the user clicks on the 'Bestätigen' button.
  // It checks the value of 'widget.boxname' to determine which type of box is being selected.
  // Based on the box type, it extracts the selected values from the dropdown menus and formats them accordingly.
  // Finally, it calls the 'onItemSelected' callback with the formatted text as a parameter.
  void _onSubmit() {
    if (widget.boxname == 'schueler') {
      // If the box type is 'schueler', split the selectedStudent string by ' | ' delimiter
      // and create a map with the formatted text to pass to the 'onItemSelected' callback.
      List<String> student = selectedStudent!.split(' | ');
      widget.onItemSelected({
        'text': '${student[0]}\n${student[1]}\n${student[2]}',
      });
    } else if (widget.boxname == 'erzieher') {
      // If the box type is 'erzieher', split the selectedParent string by '\n' delimiter
      // and further split the name and contact strings by ' | ' delimiter.
      // Create a map with the formatted text to pass to the 'onItemSelected' callback.
      List<String> parent = selectedParent!.split('\n');
      List<String> name = parent[0].split(' | ');
      List<String> contact = parent[1].split(' | ');
      widget.onItemSelected({
        'text': '${name[0]}\n${name[1]}\n${contact[0]}\n${contact[1]}',
      });
    } else if (widget.boxname == 'addresse') {
      // If the box type is 'addresse', split the selectedAdresse string by '\n' delimiter
      // and further split the street and postal strings by ' | ' delimiter.
      // Create a map with the formatted text to pass to the 'onItemSelected' callback.
      List<String> address = selectedAdresse!.split('\n');
      List<String> street = address[0].split(' | ');
      List<String> postal = address[1].split(' | ');
      widget.onItemSelected({
        'text': '${street[0]}-${street[1]}\n${postal[0]}\n${postal[1]}',
      });
    } else {
      // For any other box type, create a map with the selectedAG1, selectedAG2, and selectedAG3 values
      // and pass it to the 'onItemSelected' callback.
      widget.onItemSelected({
        'text': '${selectedAG1!}\n${selectedAG2!}\n${selectedAG3!}',
      });
    }
  }
}
