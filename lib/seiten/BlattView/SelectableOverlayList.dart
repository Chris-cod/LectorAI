import 'package:flutter/material.dart';

class SelectableOverlayList extends StatefulWidget {
  var items;
  final ValueChanged<Map<String, dynamic>> onItemSelected;
  final String boxname;

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

  List<String> studentItems = [];
  List<String> parentItems = [];
  List<String> adresseItems = [];
  List<String> ag1 = [];
  List<String> ag2 = [];
  List<String> ag3 = [];

  @override
  void initState() {
    super.initState();
    _initializeItems();
  }

  void _initializeItems() {
    if(widget.boxname == 'schueler') {
      for (var item in widget.items) {
        studentItems.add('${item['lastname']} | ${item['firstname']} | ${item['school_class']}');
      }
    } else if(widget.boxname == 'erzieher') {
      for (var item in widget.items) {
        parentItems.add('${item['parent']['lastname']} | ${item['parent']['firstname']}\n${item['parent']['phone_number']} | ${item['parent']['email']}');
      }
    } else if(widget.boxname == 'addresse') {
      for (var item in widget.items) {
        adresseItems.add('${item['street_name']} | ${item['house_number']}\n${item['postal_code']} | Bremen');
      }
    } else {
      if (widget.items['ag_1'] != null) {
        for (var ag in widget.items['ag_1']) {
          ag1.add(ag['name']);
        }
      }

      if (widget.items['ag_2'] != null) {
        for (var ag in widget.items['ag_2']) {
          ag2.add(ag['name']);
        }
      }

      if (widget.items['ag_3'] != null) {
        for (var ag in widget.items['ag_3']) {
          ag3.add(ag['name']);
        }
      }
    }
  }

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
                      _buildOverlayText(widget.boxname),
                      const SizedBox(height: 10),
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
                style: const TextStyle(fontSize: 16, color: Colors.black),
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
                style: const TextStyle(fontSize: 12, color: Colors.black),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG1 = newValue;
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG2 = newValue;
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    onChanged: (newValue) {
                      setState(() {
                        selectedAG3 = newValue;
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
      // Add more cases for 'erzieher', 'addresse' as needed
      default:
        return Container();
    }
  }


  void _onSubmit() {
    if (widget.boxname == 'schueler') {
      List<String> student = selectedStudent!.split(' | ');
      widget.onItemSelected({
        'selectedStudent': '${student[0]}\n${student[1]}\n${student[2]}',
      });
    } else if (widget.boxname == 'erzieher') {
      List<String> parent = selectedParent!.split('\n');
      List<String> name = parent[0].split(' | ');
      List<String> contact = parent[1].split(' | ');
      widget.onItemSelected({
        'selectedErzieher': '${name[0]}\n${name[1]}\n${contact[0]}\n${contact[1]}',
      });
    } else if (widget.boxname == 'addresse') {
      List<String> address = selectedAdresse!.split('\n');
      List<String> street = address[0].split(' | ');
      List<String> postal = address[1].split(' | ');
      widget.onItemSelected({
        'selectedAdresse': '${street[0]}-${street[1]}\n${postal[0]}\n${postal[1]}',
      });
    } else {
      widget.onItemSelected({
        'selectedAGs': '${selectedAG1!}\n${selectedAG2!}\n${selectedAG3!}',
      });
    }
  }
}
