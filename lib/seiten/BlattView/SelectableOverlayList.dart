import 'package:flutter/material.dart';

class SelectableOverlayList extends StatefulWidget {
  var items;
  String boxname;
  final ValueChanged<Map<String, dynamic>> onItemSelected;

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOverlayText(widget.boxname),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.items.length - 1,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              var selectedItem = widget.items[index + 1];
                              if (widget.boxname == 'schueler') {
                                int personId = selectedItem['id'];
                                widget.onItemSelected({
                                  'text': '${selectedItem['firstname']['value']}\n${selectedItem['lastname']['value']}\n${selectedItem['school_class']['value']}',
                                  'id': personId,
                                });
                              } else if (widget.boxname == 'erzieher') {
                                int parentId = selectedItem['parent'][0]['id'];
                                widget.onItemSelected({
                                  'text': '${selectedItem['parent'][0]['firstname']['value']} ${selectedItem['parent'][0]['lastname']['value']}\n${selectedItem['parent'][0]['phone_number']['value']}\n${selectedItem['parent'][0]['email']['value']}',
                                  'id': parentId,
                                });
                              } else if (widget.boxname == 'addresse') {
                                int addressId = selectedItem['id'];
                                widget.onItemSelected({
                                  'text': '${selectedItem['street_name']['value']} ${selectedItem['house_number']}\n${selectedItem['location']['postal_code']}\n${selectedItem['location']['location_name']}',
                                  'id': addressId,
                                });
                              } else {
                                int agPointer = index + 2;
                                List<int> agIds = [];
                                var selectedItemAG = widget.items['ag_$agPointer'];
                                if (selectedItemAG != null && selectedItemAG.length == 3) {
                                  agIds.add(selectedItemAG[0]['id']);
                                  agIds.add(selectedItemAG[1]['id']);
                                  agIds.add(selectedItemAG[2]['id']);
                                  widget.onItemSelected({
                                    'text': '${selectedItemAG[0]['ag_name']['value']}\n${selectedItemAG[1]['ag_name']['value']}\n${selectedItemAG[2]['ag_name']['value']}',
                                    'id': agIds,
                                  });
                                } else if (selectedItemAG != null && selectedItemAG.length == 2) {
                                  agIds.add(selectedItemAG[0]['id']);
                                  agIds.add(selectedItemAG[1]['id']);
                                  widget.onItemSelected({
                                    'text': '${selectedItemAG[0]['ag_name']['value']}\n${selectedItemAG[1]['ag_name']['value']}',
                                    'id': agIds,
                                  });
                                } else if (selectedItemAG != null && selectedItemAG.length == 1) {
                                  agIds.add(selectedItemAG[0]['id']);
                                  widget.onItemSelected({
                                    'text': '${selectedItemAG[0]['ag_name']['value']}',
                                    'id': agIds,
                                  });
                                }
                              }
                              print('Tapped item $index');
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: _buildListTextContent(widget.items, widget.boxname, index),
                              ),
                            ),
                          );
                        },
                      ),
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
              ],
            )
          : SizedBox.shrink(),
    ),
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
      text = 'Für diese Schule wurden folgende AGs gefunden.\nWählen Sie aus der Liste die richtigen AGs.';
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

  Widget _buildListTextContent(var data, String boxname, int index) {
    final String listText;
    int pointer = index + 1;
    if (boxname == 'schueler') {
      listText = '${data[pointer]['firstname']['value']} ${data[pointer]['lastname']['value']}, ${data[pointer]['school_class']['value']}';
    } else if (boxname == 'erzieher') {
      listText = '${data[pointer]['parent'][0]['firstname']['value']} ${data[pointer]['parent'][0]['lastname']['value']}, ${data[pointer]['parent'][0]['phone_number']['value']}, ${data[pointer]['parent'][0]['email']['value']}';
    } else if (boxname == 'addresse') {
      listText = '${data[pointer]['street_name']['value']} ${data[pointer]['house_number']}, ${data[pointer]['location']['location_name']} ${data[pointer]['location']['postal_code']}';
    } else {
      int agPointer = pointer + 1;
      var ag = data['ag_$agPointer'];
      if (ag != null && ag.length == 3) {
        listText = '${ag[0]['ag_name']['value']} ${ag[1]['ag_name']['value']} ${ag[2]['ag_name']['value']}';
      } else if (ag != null && ag.length == 2) {
        listText = '${ag[0]['ag_name']['value']} ${ag[1]['ag_name']['value']}';
      } else if (ag != null && ag.length == 1) {
        listText = '${ag[0]['ag_name']['value']}';
      } else {
        listText = 'Keine AGs gefunden';
      }
    }
    return FittedBox(
      child: Text(
        listText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
