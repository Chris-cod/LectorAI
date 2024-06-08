

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';
import 'package:lectorai_frontend/services/repository.dart';

class SchuelerDetails extends StatefulWidget {
  
  const SchuelerDetails({super.key, required this.token, required this.schuelerId});

  final String token;
  final int schuelerId;

  @override
  ShowSchuelerDetails createState() => ShowSchuelerDetails();
}

class ShowSchuelerDetails extends State<SchuelerDetails> {
  SchuelerInfo? schuelerInfo;
  Repository repository = Repository();

  @override
  void initState() {
    super.initState();
    initList();
  }

  initList() async {
    var schulerInformation = await repository.getStudentInformation(widget.token, widget.schuelerId);
      //schuelerInfo = alleSchueler.firstWhere((element) => element.id == widget.schuelerId);
      setState(() {
        schuelerInfo = schulerInformation;
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${schuelerInfo?.vorname ?? 'max'} ${schuelerInfo?.nachname ?? 'muster'}',
          style: const TextStyle(color: Colors.black),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xff48CAE4),
      ),
      body: schuelerInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(10.0),
              color: const Color(0xFFB9B5C6),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xffCAF0F8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildInfoCartName('Erziehungsberechtigter', Icons.person),
                          const SizedBox(height: 5.0),
                          buildInfoField('Vorname', '${schuelerInfo!.kontakt.vorname}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('Nachname', '${schuelerInfo!.kontakt.nachname}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('E-mail', '${schuelerInfo!.kontakt.email}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('Telefon', '${schuelerInfo!.kontakt.telefonnummer}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xffCAF0F8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildInfoCartName('Adresse', Icons.home),
                          const SizedBox(height: 5.0),
                          buildInfoField('Straße', '${schuelerInfo!.adresse.strasse}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('Hausnummer', '${schuelerInfo!.adresse.hausnummer}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('PLZ', '${schuelerInfo!.adresse.postleitzahl}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('Stadt', 'Bremen'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0xffCAF0F8),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildInfoCartName('AGs', Icons.group),
                          const SizedBox(height: 5.0),
                          buildInfoField('AG Wahl 1', '${schuelerInfo!.ags[0]}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('AG Wahl 2', '${schuelerInfo!.ags[1]}'),
                          const SizedBox(height: 5.0),
                          buildInfoField('AG Wahl 3', '${schuelerInfo!.ags[2]}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildInfoCartName(String cardName, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 5),
        Text(
          cardName,
          style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );

  }

  Widget buildInfoField(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffADE8F4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$label: $value',
          style: const TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
    );
  }
}
