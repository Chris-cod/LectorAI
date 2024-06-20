

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lectorai_frontend/models/schueler_info.dart';
import 'package:lectorai_frontend/services/repository.dart';

class SchuelerDetails extends StatefulWidget {
  
  const SchuelerDetails({super.key, required this.token, required this.schuelerId, required this.demoModus});

  final String token;
  final int schuelerId;
  final bool demoModus;

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
    SchuelerInfo schulerInformation;
    if (widget.demoModus) {
      schulerInformation = await repository.fetchStudentInfoFromLocalJson(
          widget.token, widget.schuelerId);
    }
    else {
      schulerInformation =
      await repository.getStudentInformation(widget.token, widget.schuelerId);
    }
    //schuelerInfo = alleSchueler.firstWhere((element) => element.id == widget.schuelerId);
    setState(() {
      schuelerInfo = schulerInformation;
    });
  }


  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${schuelerInfo?.vorname ?? 'max'} ${schuelerInfo?.nachname ??
              'muster'}',
          textAlign: TextAlign.center,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(15.0),
            height: 10,
            child: Icon(
              Icons.arrow_back,
              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,  // Dynamically set color based on theme
            ),
          ),
        ),
      ),
      body: schuelerInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildInfoCartName('Erziehungsberechtigter', Icons.person),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'Vorname', '${schuelerInfo!.kontakt.vorname}'),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'Nachname', '${schuelerInfo!.kontakt.nachname}'),
                    const SizedBox(height: 5.0),
                    buildInfoField('E-mail', '${schuelerInfo!.kontakt.email}'),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'Telefon', '${schuelerInfo!.kontakt.telefonnummer}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildInfoCartName('Adresse', Icons.home),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'Straße', '${schuelerInfo!.adresse.strasse}'),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'Hausnummer', '${schuelerInfo!.adresse.hausnummer}'),
                    const SizedBox(height: 5.0),
                    buildInfoField(
                        'PLZ', '${schuelerInfo!.adresse.postleitzahl}'),
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
        const SizedBox(width: 5),
        Text(
          cardName,
          style: const TextStyle(
               fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget buildInfoField(String label, String value) {
    var theme = Theme.of(context); // Accessing the current theme
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, // Use a suitable color from the theme
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            // Ensures the shadow is visible in both light and dark mode
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$label: $value',
          style: TextStyle(color: theme.textTheme.bodyMedium!
              .color), // Ensuring text color is also theme-based
        ),
      ),
    );
  }

}