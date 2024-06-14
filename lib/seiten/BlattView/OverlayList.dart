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
                      onItemSelected('${selectedItem['vorname']['value']}\n${selectedItem['nachname']['value']}\n${selectedItem['class']['value']}');
                    }
                    else if(boxname == 'erzieher'){
                      onItemSelected('${selectedItem['parents'][0]['vorname']['value']}\n${selectedItem['parents'][0]['nachname']['value']}\n${selectedItem['parents'][0]['email']['value']}\n${selectedItem['parents'][0]['telefone']['value']}');
                    }
                    else if(boxname == 'addresse'){
                      onItemSelected('${selectedItem['street_name']['value']}\n${selectedItem['location']['location_name']}\n${selectedItem['location']['postal_code']}');
                    }
                    else{
                      int agPointer = index + 2;
                      var selectedItemAG = items['AG$agPointer'];
                      print(selectedItemAG[0]['name']['value']);
                      onItemSelected('${selectedItemAG[0]['name']['value']}\n${selectedItemAG[1]['name']['value']}\n${selectedItemAG[2]['name']['value']}');
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
      listText = '${data[pointer]['vorname']['value']} ${data[pointer]['nachname']['value']}, ${data[pointer]['class']['value']}';
    }
    else if(boxname  == 'erzieher'){
      listText = '${data[pointer]['parents'][0]['vorname']['value']} ${data[pointer]['parents'][0]['nachname']['value']},${data[pointer]['parents'][0]['email']['value']}, ${data[pointer]['parents'][0]['telefone']['value']}';
    }
    else if(boxname == 'addresse'){
      listText = '${data[pointer]['street_name']['value']} ${data[pointer]['location']['location_name']}, ${data[pointer]['location']['postal_code']}';
    }
    else{
      int agPointer = pointer + 1;
      listText = '${data['AG$agPointer'][0]['name']['value']} ${data['AG$agPointer'][1]['name']['value']} ${data['AG$agPointer'][2]['name']['value']}';
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