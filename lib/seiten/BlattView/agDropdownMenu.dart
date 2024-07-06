import 'package:flutter/material.dart';

class ViewAGPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String boxname;
  final int index;

  const ViewAGPage({Key? key, required this.data, required this.boxname, required this.index}) : super(key: key);

  @override
  _ViewAGPageState createState() => _ViewAGPageState();
}

class _ViewAGPageState extends State<ViewAGPage> {
  // Store selected values
  String? selectedAG1;
  String? selectedAG2;
  String? selectedAG3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AG Auswahl'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAGDropdown('ag_1', (value) {
              setState(() {
                selectedAG1 = value;
              });
            }),
            _buildAGDropdown('ag_2', (value) {
              setState(() {
                selectedAG2 = value;
              });
            }),
            _buildAGDropdown('ag_3', (value) {
              setState(() {
                selectedAG3 = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  // Method to build DropdownButton for AGs
  Widget _buildAGDropdown(String agKey, Function(String?) onChanged) {
    var agList = widget.data[agKey];
    int pointer = widget.index + 1;

    if (agList != null && pointer < agList.length) {
      var ag = agList[pointer];
      if (ag != null && ag.isNotEmpty) {
        return DropdownButton<String>(
          value: ag == selectedAG1 ? selectedAG1 : ag == selectedAG2 ? selectedAG2 : selectedAG3,
          hint: Text('Wähle AG'),
          items: ag.map<DropdownMenuItem<String>>((agItem) {
            return DropdownMenuItem<String>(
              value: agItem['name'],
              child: Text(agItem['name']),
            );
          }).toList(),
          onChanged: onChanged,
        );
      }
    }
    return DropdownButton<String>(
      value: null,
      hint: Text('Keine AG vorhanden'),
      items: [],
      onChanged: null,
    );
  }
}
