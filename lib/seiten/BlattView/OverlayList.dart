import 'package:flutter/material.dart';

class OverlayList extends StatelessWidget {
  List<dynamic> items;
  String boxname;
  final ValueChanged<String> onItemSelected;

  OverlayList({required this.items, required this.onItemSelected ,required this.boxname});


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.cyan,
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
                    var selectedItem = items[index];
                    if(boxname == 'schueler'){
                      onItemSelected('${selectedItem['vorname']['value']} ${selectedItem['nachname']['value']}, ${selectedItem['class']['value']}');
                    }
                    else{
                      onItemSelected('${selectedItem['Ag_name']['value']}');
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
                      child: _buildListTextContent(items, boxname, index+1)
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
    
    if(boxname == 'schueler'){
      return const FittedBox(
      child: Text(
            'Es wurde mehrere Schüler mit diesem Namen gefunden.\n Wählen Sie aus der Liste den richtigen Namen.',
            style:  TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
      );
    }
    else{
      return const FittedBox(
      child: Text(
            'Für diese Schuele wurde folgende AGs gefunden.\n Wählen Sie aus der Liste die richtige AGs.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
      );
    }
    
  }

  Widget _buildListTextContent(var data, String boxname, int index) {
    
    if(boxname == 'schueler'){
      return FittedBox(
      child: Text(
            '${data[index]['vorname']['value']} ${data[index]['nachname']['value']}, ${data[index]['class']['value']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      );
    }
    else{
      return FittedBox(
      child: Text(
            '${data[index]['Ag_name']['value']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      );
    }
    
  }


}