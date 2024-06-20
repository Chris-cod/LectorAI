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
      schulerInformation = await repository.fetchStudentInfoFromLocalJson(widget.token, widget.schuelerId);
    } else {
      schulerInformation = await repository.getStudentInformation(widget.token, widget.schuelerId);
    }
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
          '${schuelerInfo?.vorname ?? 'max'} ${schuelerInfo?.nachname ?? 'muster'}',
          textAlign: TextAlign.center,
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: schuelerInfo == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            buildCard(
              context,
              'Erziehungsberechtigter',
              [
                buildInfoField('Vorname', '${schuelerInfo!.kontakt.vorname}'),
                buildInfoField('Nachname', '${schuelerInfo!.kontakt.nachname}'),
                buildInfoField('E-mail', '${schuelerInfo!.kontakt.email}'),
                buildInfoField('Telefon', '${schuelerInfo!.kontakt.telefonnummer}'),
              ],
            ),
            const SizedBox(height: 20.0),
            buildCard(
              context,
              'Adresse',
              [
                buildInfoField('Straße', '${schuelerInfo!.adresse.strasse}'),
                buildInfoField('Hausnummer', '${schuelerInfo!.adresse.hausnummer}'),
                buildInfoField('PLZ', '${schuelerInfo!.adresse.postleitzahl}'),
                buildInfoField('Stadt', 'Bremen'),
              ],
            ),
            const SizedBox(height: 20.0),
            buildCard(
              context,
              'AGs',
              [
                buildInfoField('AG Wahl 1', '${schuelerInfo!.ags[0]}'),
                buildInfoField('AG Wahl 2', '${schuelerInfo!.ags[1]}'),
                buildInfoField('AG Wahl 3', '${schuelerInfo!.ags[2]}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildInfoField(String label, String value) {
    var theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '$label: $value',
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
      ),
    );
  }
}
