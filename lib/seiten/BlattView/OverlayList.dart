import 'package:flutter/material.dart';

class OverlayList extends StatelessWidget {
  var items;
  String boxname;
  final ValueChanged<String> onItemSelected;

  OverlayList({required this.items, required this.onItemSelected ,required this.boxname});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Color(0xff3d7c88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlayText(boxname),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: items.length - 1,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    var selectedItem = items[index+1];
                    if(boxname == 'schueler'){
                      onItemSelected('${selectedItem['firstname']['value']}\n${selectedItem['lastname']['value']}\n${selectedItem['school_class']['value']}');
                    }
                    else if(boxname == 'erzieher'){
                      onItemSelected('${selectedItem['parent'][0]['firstname']['value']}\n${selectedItem['parent'][0]['lastname']['value']}\n${selectedItem['parent'][0]['phone_number']['value']}\n${selectedItem['parent'][0]['email']['value']}');
                    }
                    else if(boxname == 'addresse'){
                      onItemSelected('${selectedItem['street_name']['value']} ${selectedItem['house_number']['value']}\n${selectedItem['location']['location_name']}\n${selectedItem['location']['postal_code']}');
                    }
                    else{
                      int agPointer = index + 2;
                      var selectedItemAG = items['ag_$agPointer'];
                      if(selectedItemAG != null && selectedItemAG.length == 3){
                        onItemSelected('${selectedItemAG[0]['ag_name']['value']}\n${selectedItemAG[1]['ag_name']['value']}\n${selectedItemAG[2]['ag_name']['value']}');
                      }
                      else if(selectedItemAG != null && selectedItemAG.length == 2){
                        onItemSelected('${selectedItemAG[0]['ag_name']['value']}\n${selectedItemAG[1]['ag_name']['value']}');
                      }
                      else if(selectedItemAG != null && selectedItemAG.length == 1){
                        onItemSelected('${selectedItemAG[0]['ag_name']['value']}');
                      }
                      // print(selectedItemAG[0]['name']['value']);
                      // onItemSelected('${selectedItemAG[0]['name']['value']}\n${selectedItemAG[1]['name']['value']}\n${selectedItemAG[2]['name']['value']}');
                    }
                    //onItemSelected(items[index]);
                    print('tapped Item $index');
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _buildListTextContent(items, boxname, index)
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayText(String boxname) {
    final String text;
    if(boxname == 'schueler'){
      text = 'durch Analyse könnte mehrere Schüler mit diesem Namen gefunden werden.\n Wählen Sie aus der Liste den richtigen Namen.';
    }
    else if(boxname  == 'erzieher'){
      text = 'Nach Analyse wurde mehrere Erzieher gefunden.\n Wählen Sie aus der Liste den richtigen Erzieherberechtigte/r.';
    }
    else if(boxname == 'addresse'){
      text = 'durch KI-Analyse wurde mehrere Adressen gefunden.\n Wählen Sie aus der Liste die richtige Adresse.';
    }
    else{
      text = 'Für diese Schuele wurde folgende AGs gefunden.\n Wählen Sie aus der Liste die richtige AGs.';
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
    if(boxname == 'schueler'){
      listText = '${data[pointer]['firstname']['value']} ${data[pointer]['lastname']['value']}, ${data[pointer]['school_class']['value']}';
    }
    else if(boxname  == 'erzieher'){
      listText = '${data[pointer]['parent'][0]['firstname']['value']} ${data[pointer]['parent'][0]['lastname']['value']},${data[pointer]['parent'][0]['phone_number']['value']}, ${data[pointer]['parent'][0]['email']['value']}';
    }
    else if(boxname == 'addresse'){
      listText = '${data[pointer]['street_name']['value']} ${data[pointer]['house_number']['value']} ${data[pointer]['location']['location_name']}, ${data[pointer]['location']['postal_code']}';
    }
    else{
      int agPointer = pointer + 1;
      var ag = data['ag_$agPointer'];
      if(ag != null && ag.length == 3){
        listText = '${ag[0]['ag_name']['value']} ${ag[1]['ag_name']['value']} ${ag[2]['ag_name']['value']}';
      }
      else if(ag != null && ag.length == 2){
        listText = '${ag[0]['ag_name']['value']} ${ag[1]['ag_name']['value']}';
      }
      else if(ag != null && ag.length == 1){
        listText = '${ag[0]['ag_name']['value']}';
      }
      else{
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