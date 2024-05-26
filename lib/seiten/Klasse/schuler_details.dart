

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';

class SchuelerDetails extends StatefulWidget {
  
  const SchuelerDetails({super.key, required this.schuelerName});

  final String schuelerName;

  @override
  ShowSchuelerDetails createState() => ShowSchuelerDetails();
}


class ShowSchuelerDetails extends State<SchuelerDetails>{
  SchuelerInfo? schuelerInfo;

  @override
  void initState() {
    super.initState();
    initList();
  }

  initList() {
    readJsonFile('schuelerInfoKlasse12A').then((jsonList) {
      final alleSchueler = jsonList.map((json) => SchuelerInfo.fromJson(json)).toList();
      //schuelerInfo = alleSchueler.firstWhere((element) => element.id == widget.schuelerId);
      setState(() {
        schuelerInfo = alleSchueler.firstWhere((element) => element.vorname == widget.schuelerName);
      });
    });
  }

  Future<List<dynamic>> readJsonFile(String fileName) async {
    try {
      final String response = await rootBundle.loadString('assets/Daten/$fileName.json');
      final schulerData = await json.decode(response);
      var slist = schulerData["schueler"] as List<dynamic>;
      return slist;
    } catch (e) {
      print('Fehler beim Laden der Schülerdaten: $e');
      return List.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('${schuelerInfo?.vorname?? 'max'} ${schuelerInfo?.nachname?? 'muster'}', style: const TextStyle(color: Colors.black), textAlign: TextAlign.center,),
        backgroundColor: const Color(0xff48CAE4),
      ),
      body: schuelerInfo == null ? const Center(child: CircularProgressIndicator()) : Container(
        padding: const EdgeInsets.all(10.0),
        color: const Color(0xFF0077B6),
        child: Column(
          children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xffCAF0F8),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                buildInfoCartName('Erziehungsberechtigte/r'),
                const SizedBox(height: 5.0),
                buildInfoField('Vorname', '${schuelerInfo!.kontakt.vorname}'),
                const SizedBox(height: 5.0),
                buildInfoField('Nachname', '${schuelerInfo!.kontakt.nachname}'),
                const SizedBox(height: 5.0),
                buildInfoField('E-mail', '${schuelerInfo!.kontakt.email}'),
                const SizedBox(height: 5.0),
                buildInfoField('Telefon', '${schuelerInfo!.kontakt.telefonnummer}'),
              ]
            )
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xffCAF0F8),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                buildInfoCartName('Adresses'),
                const SizedBox(height: 5.0),
                buildInfoField('Straße', '${schuelerInfo!.adresse.strasse}'),
                const SizedBox(height: 5.0),
                buildInfoField('Hausnummer', '${schuelerInfo!.adresse.hausnummer}'),
                const SizedBox(height: 5.0),
                buildInfoField('PLZ', '${schuelerInfo!.adresse.postleitzahl}'),
                const SizedBox(height: 5.0),
                buildInfoField('Stadt', 'Bremen'),
              ]
            )
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xffCAF0F8),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                buildInfoCartName('AGs'),
                const SizedBox(height: 5.0),
                buildInfoField('AG Wahl 1', '${schuelerInfo!.ags[0]}'),
                const SizedBox(height: 5.0),
                buildInfoField('AG Wahl 2', '${schuelerInfo!.ags[1]}'),
                const SizedBox(height: 5.0),
                buildInfoField('AG Wahl 3', '${schuelerInfo!.ags[2]}'),
              ]
            )
          ),
        ],
        )
        
      ),
    );
  }

   Widget buildInfoCartName(String cardName) {
    return  SizedBox(
          width: 175,
          height: 20,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              cardName,
              style: const TextStyle(color: Colors.black, fontSize: 15),
          ),
        ),
      );
    
  }

  Widget buildInfoField(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffADE8F4),
        borderRadius: BorderRadius.circular(25),
      ), 
      child:SizedBox(
          width: 250,
          height: 35,
          child: Align(
              alignment: Alignment.center,
              child: Text(
                '$label: $value',
                style: const TextStyle(color: Colors.black, fontSize: 15),
              )),
        )
    );
  }
}

