import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lectorai_frontend/seiten/BlattView/OverlayList.dart';
import 'package:lectorai_frontend/seiten/CamerPage/ViewImagePage.dart';
import 'package:lectorai_frontend/services/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PdfViwer extends StatefulWidget {
  
  const PdfViwer({super.key, required this.authToken, required this.imageBytes, required this.demoModus});

  final String authToken; // Authentifizierungstoken für die Kommunikation mit dem Backend
  final Uint8List imageBytes; // Bild, das gescannt wurde
  final bool demoModus; // Demo-Modus

  @override
  PdfViwerState createState() => PdfViwerState();
}

class PdfViwerState extends State<PdfViwer> with WidgetsBindingObserver{
  int? currentPage = 0;
  bool pdfReady = false;
  OverlayEntry? _overlayEntry, _secondOverlay;
  // ignore: unused_field
  late PDFViewController _controller;
  String? path, displayTextErzieher, displayTextStudent, displayTextAdresse, displayTextAG, docType, housNummer;
  Map<String, dynamic> _jsonData = {};
  Map<String, dynamic> _changeData = {};
  bool dataLoaded = false;
  bool personIsChecked = false;
  bool parentIsChecked = false;
  bool addressIsChecked = false;
  bool agIsChecked = false;
  bool isChecked = false;
  bool isSaved = false;
  bool hideSaveButton = true;
  bool isSigned = false;
  bool isOverLayVisible = false;
  bool isGestureDetectorActive = true;
  bool? desableDbComparison, dontSaveChanges;
  final int _currentIndex = 0;
  int? personId, parentId, addressId;
  List<int> agIds = [];
  double? personScore, parentScore, addressScore, agScore;
  Repository repository = Repository();
  List<String> type = ['ad', 'ag', 'agNS', 'adNS']; // Liste des Teil von JSON-Dateien 
  Color? personColor, parentColor, addressColor, agColor, signatureColor;
  String? signature;
  
  

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    fetchDataAndSetting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  /*
    + fetchDataAndSetting() - Methode zum Abrufen der Daten und Einstellungen,
    + die für die Anzeige des PDFs erforderlich sind.
    + die Methode ruft die Methode sendImage() aus dem Repository auf, um das Bild an backend zu senden
    + und die Antwort als JSON-Objekt zu erhalten.
    + Die Methode verwendet SharedPreferences, um die Einstellungen zu speichern und abzurufen.
    + Die Methode verwendet die Methode getFileFromAsset(), um das PDF-Datei aus dem Asset-Ordner zu erhalten.
    + in demo modus wird die Methode getRandomDemoDocType() verwendet, um zufällig ein json datei auszuwählen.

   */
  Future<void> fetchDataAndSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    desableDbComparison = prefs.getBool('desableDbComparison') ?? false; // werte von desableDbComparison aus shared preferences abrufen, um die Datenbankvergleich zu deaktivieren
    dontSaveChanges = prefs.getBool('dontSaveChanges') ?? false; // werte von dontSaveChanges aus shared preferences abrufen, um die Änderungen nicht zu speichern
    print('Aktuelle no_db value: $desableDbComparison');
    Map<String, dynamic> responseJson;
    if(widget.demoModus){
      var str = getRandomDemoDocType(type);
      final String response = await rootBundle.loadString('assets/Daten/${str}_sample.json'); // json datei aus dem Asset-Ordner lesen
      responseJson = json.decode(response);
      docType = responseJson['doc_type']; // Dokumententyp aus dem JSON-Objekt erhalten
    }
    else{
      responseJson = await repository.sendImage(context, widget.authToken, widget.imageBytes, desableDbComparison!);
      docType = desableDbComparison!? responseJson['doc_type'] : responseJson['doc_type']; // Dokuemntentyp aus dem JSON-Objekt von backend erhalten
    }
    
    
    var f = await getFileFromAsset("assets/Doc/$docType.pdf"); // PDF-Datei aus dem Asset-Ordner laden
    setState(() {
      _jsonData = responseJson;
      path = f.path;
      _showOverlay();
    });

    print(path);
  }


  /*
    diese methood wird aufgerufen, um das DOkuemnt aus dem Asset-Ordner zu laden
  */
  Future<File> getFileFromAsset(String asset) async {
    Completer<File> completer = Completer();
    String fileType = asset.split('/').last;
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$fileType");
      print(file.path);
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      File assetFile = await file.writeAsBytes(bytes);
      completer.complete(assetFile);
    } catch (e) {
      throw Exception("Error opening asset file: $e");
    }
    return completer.future;
  }

  /*
    diese method ist gernutzt um zufaellig ein json datei in demo modus auszuwählen
  */
  String getRandomDemoDocType(List<String> list) {
    final random = Random();
    int index = random.nextInt(list.length);
    return list[index];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Methode zum Erstellen eines Overlays, das die Informationen abhängig vom Dokumententyp anzeigt
  void _showOverlay() {
    if(isChecked){
      _overlayEntry?.remove();
      _overlayEntry = _changeOverlayBorder(Colors.green);
      if(_overlayEntry != null){
        Overlay.of(context).insert(_overlayEntry!);
        setState(() {
          isOverLayVisible = true;
        });
      }
      
    }
    else{
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry();
      if(_overlayEntry != null){
        Overlay.of(context).insert(_overlayEntry!);
        setState(() {
          isOverLayVisible = true;
        });
      }
    }
  }

// hier wird die Methode didChangeDependencies() überschrieben, um die Änderungen zu verfolgen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      isOverLayVisible = true;
    } else if (state == AppLifecycleState.paused) {
      removeFirstOverlay();
    }
  }

// hier wird der Overlay zum Auswählen oder eintragen der Information angezeigt
// die Methode wird aufgerufen, wenn der Benutzer auf den Edit-Icon klickt
  void _showSecondOverlay(var data , String boxname) {
    _secondOverlay?.remove();
    _secondOverlay = _createOverlayList(context, data, boxname);
    Overlay.of(context).insert(_secondOverlay!);
  }

  void removeFirstOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void removeSecondOverlay() {
    _secondOverlay?.remove();
    _secondOverlay = null;
  }

  void _restoreOverlay() {
    setState(() {
      _showOverlay();
    });
  }

  // hier wird das Dokument auf das Bildschirm angezeigt, mit den Overlays und daten
  // Dazu wird das Speichern-Button angezeigt, wenn alle Daten überprüft und bestätigt sind 
  @override
  Widget build(BuildContext context) {
      return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
              title: const Text("Erfasste Informationen"),
              leading: GestureDetector(
                  onTap: () {
                    if(isChecked){
                      isOverLayVisible = false;
                      removeFirstOverlay();
                      removeSecondOverlay();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                    else{
                      isOverLayVisible = false;
                      removeFirstOverlay();
                      removeSecondOverlay();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.all(15.0),
                      height: 10,
                      child: Image.asset('assets/Bilder/_.png', color: Colors.black, scale: 1.0,),
                  )
              ),
              // Action um das gescannt Dokument zu sehen
              actions: !isChecked
                  ? [
                      IconButton(
                          icon: Icon(Icons.remove_red_eye, size: MediaQuery.of(context).size.width * 0.05),
                          onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewImagePage(imageBytes: widget.imageBytes, onReturn: _restoreOverlay,),
                                  ),
                              ).then((value) => _restoreOverlay());
                              setState(() {
                                  isOverLayVisible = false;
                              });
                              removeSecondOverlay();
                          },
                      ),
                  ]
                  : null,
          ),
          body: path != null
              ? Stack(
                  children: [
                    // Darsellung des PDF-Dokuments
                      PDFView(
                          filePath: path,
                          enableSwipe: true,
                          swipeHorizontal: true,
                          autoSpacing: false,
                          pageFling: true,
                          pageSnap: true,
                          defaultPage: currentPage!,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation: false,
                          onError: (e) {
                              print(e);
                          },
                          onRender: (pages) {
                              setState(() {});
                          },
                          onViewCreated: (PDFViewController vc) {
                              _controller = vc;
                          },
                          onPageError: (page, e) {
                              print(e);
                          },
                      ),
                      // Widget zur Verhinderung der Interaktion (Zoom) mit dem PDF
                      Positioned.fill(
                          child: GestureDetector(
                              onScaleStart: (_) {},
                              onScaleUpdate: (_) {},
                              onScaleEnd: (_) {},
                              onDoubleTap: isGestureDetectorActive ? () {} : null
                          ),
                      ),
                      if (!hideSaveButton)
                          Positioned(
                              bottom: 20,
                              left: MediaQuery.of(context).size.width * 0.25,
                              right: MediaQuery.of(context).size.width * 0.25,
                              child: buildSaveChangeButton(),
                          ),
                  ],
              )
              : const Center(child: CircularProgressIndicator()),
      ),
      // methode zum navigieren zurück mit dem Zurück-Button von gerät 
      onWillPop: () async {
        if(isChecked){
          isOverLayVisible = false;
          removeFirstOverlay();
          removeSecondOverlay();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
        else{
          isOverLayVisible = false;
          removeFirstOverlay();
          removeSecondOverlay();
          Navigator.of(context).pop();
        }
        return true;
      },
      );
      
  }

  // Methode zum Erstellen des Overlays, das die Informationen abhängig vom Dokumententyp anzeigt
  OverlayEntry _createOverlayEntry() {
    try {
      print(docType);
      if (docType == 'Adresse' || docType == 'AD') {
        var adData = _constructADTextInformation(_jsonData);
        var student, newAdress;
        displayTextStudent = adData['student'];
        displayTextErzieher = adData['parent'];
        displayTextAdresse = adData['address'];
        personColor = _getColorFromScore(personScore!);
        parentColor = _getColorFromScore(parentScore!);
        addressColor = _getColorFromScore(addressScore!);
        print('aktuelle no_db value ${desableDbComparison!}');
        // wenn vergleich mit der Datenbank deaktiviert ist
        if(!desableDbComparison!){
          newAdress = _jsonData['addresses'];
          student = _jsonData['students'];
          var val = _jsonData['signature'];
          if(!val){
            isSigned = false;
            signature = 'Not Found';
          }
          else{
            isSigned = true;
            signature ='Found';
          }
          signatureColor = isSigned ? Colors.green : Colors.red;
        }
        else{
          var val = _jsonData['signature']['prediction'];
          if(val == null || val.isEmpty){
            isSigned = false;
            signature = 'Not Found';
          }
          else{
            isSigned = true;
            signature ='Found';
          }
          signature = !isSigned ? 'Not Found' :'Found'; 
          signatureColor = isSigned ? Colors.green : Colors.red;
        }
        // Wenn alle Daten in Json gelesen und formatiert sind
        // wird Overlay mit den Daten ausgefüllt, und angezeigt
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              Visibility(
                visible: isOverLayVisible,
                child: Stack(
                  children: [
                    _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, personColor!),// Position der Erzieher-Daten-Overlay
                    _iconsOverlay(0.445, 0.67, student, 'erzieher'),
                    _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, parentColor!), // Position der Schüler-Daten-Overlay
                    _iconsOverlay(0.547, 0.67, student, 'schueler'),
                    _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, addressColor!), // Position der Adresse-Daten-Overlay
                    _iconsOverlay(0.65, 0.67, newAdress, 'addresse'),
                    _positionedOverlaywithText('Signature: $signature', 0.5, 0.04, 0.81, 0.195, signatureColor!), // Position der Signatur-Overlay
                  ],
                ),

              ),
            ],
          ),
        );
      } 
      else {
        var student;
        print('aktuelle no_db value ${desableDbComparison!}');
        if(desableDbComparison!){
          displayTextStudent = '${_jsonData['student_lastname']?['prediction'] ?? 'Muster'}\n${_jsonData['student_firstname']?['prediction'] ?? 'Max'}\n${_jsonData['student_class']?['prediction'] ?? '0X'}';
          personScore = !isChecked ? (_jsonData['student_lastname']?['confidence'] ?? 0.0 + _jsonData['student_firstname']?['confidence'] ?? 0.0 + _jsonData['student_class']?['confidence'] ?? 0.0)/3 : 1.0;
           Map<String,dynamic> _agData =_constructAGText(_jsonData)  ;
          displayTextAG = _agData['text'];
          agScore = _agData['score'] ?? 0.0;
          var val = _jsonData['signature']['prediction'];
          if(val == null || val.isEmpty){
            isSigned = false;
            signature = 'Not Found';
          }
          else{
            isSigned = true;
            signature ='Found';
          }
          signatureColor = isSigned ? Colors.green : Colors.red;
          personColor = _getColorFromScore(personScore!);
          agColor = _getColorFromScore(agScore!);
        }
        else{
          student = _jsonData['students'];
          if(student.isEmpty){
            displayTextStudent = 'Keine Schüler gefunden';
            personScore = 0.0;
          }else{
            Map<String,dynamic> fs = student[0];
            displayTextStudent = '${fs["lastname"] ?? 'Muster'}\n${fs['firstname'] ?? 'Max'}\n${fs['school_class'] ?? '0X'}';
            personId = fs['id'];
            personScore =  fs['similarity_score'] ??  0.1;
            personColor = isChecked? Colors.green : _getColorFromScore(personScore!);
          }
          Map<String,dynamic> _agData =_constructAGText(_jsonData)  ;
          displayTextAG = _agData['text'];
          agScore = _agData['score'] ?? 0.1; 
          agColor = isChecked? Colors.green : _getColorFromScore(agScore!);
          //isSigned = _jsonData['signature'] ? true : false;
          isSigned = _jsonData['signature'];
          signature = isSigned ? 'Found' :'Not Found'; 
          signatureColor = isSigned ? Colors.green : Colors.red;
        }
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              Visibility(
                visible: isOverLayVisible,
                child: Stack(
                  children: [
                    // Position für Schüler-Daten-Container
                    _positionedOverlaywithText(displayTextStudent!,0.7, 0.108, 0.508, 0.1, personColor!),
                    // Position für Button-Container
                    _iconsOverlay(0.495, 0.66, student, 'schueler'),
                    // Position für AG-Container
                    _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, agColor!),
                    // // Position für Button-Container
                    _iconsOverlay(0.61, 0.66, _jsonData, 'ag'),
                    // Add signature box
                    _positionedOverlaywithText('Signature: $signature',0.5,0.07,0.78,0.15,signatureColor!),
                  ],
                ),

              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Fehler beim Erstellen des Overlays: $e');
      print(e.toString());
      return OverlayEntry(builder: (context) => Container());
    }
  }

  // methode zum erstellen der zweite Overlay, das die Interaktionmöglichkeit mit dem Benutzer bietet
  // abhängig zum welchen Informationsfeld der Benutzer klickt
  OverlayEntry _createOverlayList(BuildContext context, var data, String boxname){
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.5,
        top: MediaQuery.of(context).size.height * 0.10,
        left: MediaQuery.of(context).size.width * 0.10,
        child: Material(
          color: Colors.transparent,
          child: OverlayList(
            items: data,
            // Methode zum aktualisieren des Textes, wenn der Benutzer ein Element editiert oder auswählt
            onItemSelected: (selectedItem) {
              setState(() {
                if (boxname == 'erzieher') {
                  displayTextErzieher = '';
                  displayTextErzieher = selectedItem['text'];
                } else if (boxname == 'schueler') {
                  displayTextStudent = '';
                  displayTextStudent = selectedItem['text'];
                } else if (boxname == 'addresse') {
                  displayTextAdresse = '';
                  displayTextAdresse = selectedItem['text'];
                } else if (boxname == 'ag') {
                  displayTextAG = '';
                  displayTextAG = selectedItem['text'];
                }
              });
              // entfernen des zweiten Overlays, nachdem der Benutzer eine Aktion ausgeführt hat, und bestätigt hat
              removeSecondOverlay();
            }, boxname: boxname,
            isDemoModus: widget.demoModus,
          ),
        ),
      ),
    );
  }

  void showErrorOverlay(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0,
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the overlay after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }


  // methode zum positionieren des Overlay-Containers, der die Informationen anzeigt
  // abhängig von der Position und Größe des Geräts
  // dazu wird die Randfarbe fesgelegt.
  Widget _positionedOverlaywithText(String text, double widthMultiplicator, double heightMultiplicator, 
                        double topMultiplicator, double leftMultiplicator,Color score) {
    return Positioned(
      width: MediaQuery.of(context).size.width * widthMultiplicator, // Breite des Containers
      height: MediaQuery.of(context).size.height * heightMultiplicator, // Höhe des Containers
      top: MediaQuery.of(context).size.height * topMultiplicator, // Position des Containers von oben
      left: MediaQuery.of(context).size.width * leftMultiplicator, // Position des Containers von links
      child: _buildOverlayBox(
        text,
        220,
        80,
        Colors.white.withOpacity(0.3),
        score,
      ),
    );
  }

// mehtode zum darstellung der Icons-Overlay, die die Interaktion mit dem Benutzer ermöglichen
  Widget _iconsOverlay(double topMultiplicator, double leftMultiplicator, var data, String infoBox) {
    return Positioned(
      width: 180,
      height: 100,
      top: MediaQuery.of(context).size.height * topMultiplicator,
      left: MediaQuery.of(context).size.width * leftMultiplicator,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // IconButton zum Bearbeiten der Informationen
          IconButton(
            icon: const Icon(Icons.edit,
                color: Color(0xff3d7c88)), // Button-Farbe ändern
            onPressed: () {
              _showSecondOverlay(data, infoBox); // zweites Overlay anzeigen, um die Informationen zu bearbeiten
            },
          ),
          // IconButton zum Bestätigen der Informationen
          IconButton(
            icon: const Icon(Icons.check,
                color: Colors.green),
            // methode zum bestätigen der Informationen
            onPressed: () {
              setState(() {
                if (infoBox == 'schueler') {
                  personIsChecked = true;
                } else if (infoBox == 'erzieher') {
                  parentIsChecked = true;
                } else if (infoBox == 'addresse') {
                  addressIsChecked = true;
                } else if (infoBox == 'ag') {
                  agIsChecked = true;
                }
                if(parentIsChecked && personIsChecked && addressIsChecked || agIsChecked && personIsChecked){
                  isChecked = true;
                  hideSaveButton = false; //das Speichern-Buttons wird nun angezeigt
                  if(docType == 'Adresse' || docType == 'AD'){
                    _changeData = buildADChangeResponse(); // Methode zum Erstellen des JSON-Objekts für die Änderungen von Adresse-Daten zu speichern
                  }
                  else{
                    _changeData = buildAGChangeResponse(); // Methode zum Erstellen des JSON-Objekts für die Änderungen von AG-Daten zu speichern
                  }
                  _showOverlay(); // Methode zum Anzeigen des Overlays mit den bestätigten Informationen
                }
                print('Change Daten zu speichern: \n ${_changeData.toString()}');
              });
            },
          ),
        ],
      ),
    );
  }

  // methode zum Erstellen der container, die die Informationen in das Overlay anzeigt
  Widget _buildOverlayBox(
      String text, double width, double height, Color backgroundColor, Color borderColor) {
    return  Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color:  backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isChecked? Colors.green : borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown, // FittedBox hinzugefügt, um den Text responsiv zu machen
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
  }

  // methode zum Setzen der Farbe des Randes auf grün nach bestätigung der Informationen 
  // dabein werden auch alle Icon von Bildschirm entfernt
  OverlayEntry _changeOverlayBorder(Color borderColor) {
    if(docType == 'Adresse' || docType == 'AD'){
      return OverlayEntry(
        builder: (context) => Stack(
          children: [
            Visibility(
                visible: isOverLayVisible,
                child: Stack(
                  children: [
                    _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, borderColor),
                    _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, borderColor),
                    _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, borderColor),
                    _positionedOverlaywithText('Signature: $signature', 0.5, 0.04, 0.81, 0.195, signatureColor!),

                  ],
                ),
            ),
          ],
        ),
      );
    }
    else{
      return OverlayEntry(
        builder: (context) => Stack(
          children: [
            Visibility(
              visible: isOverLayVisible,
              child: Stack(
                children: [
                  _positionedOverlaywithText(displayTextStudent!,0.7, 0.108, 0.508, 0.1, borderColor),
                  _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, borderColor),
                  _positionedOverlaywithText('Signature: $signature',0.5,0.07,0.78,0.15,signatureColor!),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // hier wird das Bestätingen-Button erstellt, um die Änderungen zu speichern
  // dazu wird die Methode saveChanges() aus dem Repository aufgerufen
  // und Nachrichten für unterschiedliche Szenarien definieren und anzeigen für eine bestimmte Zeit
  Widget buildSaveChangeButton() {
    return  Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () async {
            if(widget.demoModus){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo-Modus Änderungen gespeichert'),
                    duration: Duration(seconds: 5),
                  ),
              );
            }
            else{
              if(dontSaveChanges! || desableDbComparison!){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('übertragen deaktiviert oder Antwort direck von der KI erhalten. Änderungen können nicht gespeichert werden.'),
                    duration: Duration(seconds: 5),
                  ),
              );
              }
              else{
                if(isSigned){
                  isSaved = await repository.saveChanges(widget.authToken, _changeData);
                  if(isSaved){
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Änderungen erfolgreich übertragen und gespeichert'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                  else{
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fehler beim Speichern der Änderungen'),
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
                else{
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Das Blatt wurde nicht unterschrieben. Änderungen können nicht gespeichert werden.'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
                
              }
            }
            setState(() {
              hideSaveButton = true;
            });
          },
          child: const Text('Änderungen speichern'),
        ),
      );
  }

  // Methode zum Vormatierung der Informationen für Adresseänderungen
  Map<String, dynamic> _constructADTextInformation(Map<String, dynamic> data) {
    String studentText = '';
    String parentText = '';
    String addressText = '';
    if(desableDbComparison!){
      if(data.isEmpty){
        studentText = 'Kein Schüler gefunden';
        personScore = 0.0;
        parentText = 'Kein Elternteil gefunden';
        parentScore = 0.0;
        addressText = 'Keine Adresse gefunden';
        addressScore = 0.0;
      }else{
        // Sicherstellen, dass alle benötigten Felder nicht null sind und einen Standardwert festlegen
        studentText = '${data['student_lastname']?['prediction'] ?? 'Doe'}\n'
                            '${data['student_firstname']?['prediction'] ?? 'Max'}\n'
                            '${data['student_class']?['prediction'] ?? '0X'}';

        // Berechnung des gesamten Scores für den Schüler
        num childLastNameConfidence = data['student_lastname']?['confidence'] ?? 0.1;
        num childFirstNameConfidence = data['student_firstname']?['confidence'] ?? 0.1;
        num childClassConfidence = data['student_class']?['confidence'] ?? 0.1;
        personScore = !isChecked ? (childLastNameConfidence + childFirstNameConfidence + childClassConfidence) / 3 : 1.0;

        // Sicherstellen, dass alle benötigten Felder nicht null sind und einen Standardwert festlegen
        parentText = '${data['parent_lastname']?['prediction'] ?? 'Doe'}\n'
                            '${data['parent_firstname']?['prediction'] ?? 'John'}\n'
                            '${data['phone_number']?['prediction'] ?? '0000000'}\n'
                            '${data['email']?['prediction'] ?? 'muster@web.de'}';

        // Berechnung des Scores für die Eltern
        num parentLastNameConfidence = data['parent_lastname']?['confidence'] ?? 0.1;
        num parentFirstNameConfidence = data['parent_firstname']?['confidence'] ?? 0.1;
        num parentPhoneConfidence = data['phone_number']?['confidence'] ?? 0.1;
        num parentEmailConfidence = data['email']?['confidence'] ?? 0.1;
        parentScore = !isChecked ? (parentLastNameConfidence + parentFirstNameConfidence + parentPhoneConfidence + parentEmailConfidence) / 4 : 1.0;

        // Sicherstellen, dass alle benötigten Felder nicht null sind und einen Standardwert festlegen
        addressText = '${data['street']?['prediction'] ?? 'Musterstr'} '
                            '${data['house_number']?['prediction'] ?? '00'}\n'
                            '${data['postal_code']?['prediction'] ?? '00000'}\n'
                            '${data['city']?['prediction'] ?? 'Bremen'}';

        // Berechnung des Scores für die Adresse
        num addressStreetNameConfidence = data['street']?['confidence'] ?? 0.1;
        num addressHouseNumberConfidence = data['house_number']?['confidence'] ?? 0.1;
        num addressZipConfidence = data['postal_code']?['confidence'] ?? 0.1;
        num addressCityConfidence = data['city']?['confidence'] ?? 0.1;
        addressScore = !isChecked ? (addressStreetNameConfidence + addressHouseNumberConfidence + addressZipConfidence + addressCityConfidence) / 4 : 1.0;

      }
    }else{
      var student = data['students'];
      Map<String,dynamic> firststudent = student?[_currentIndex] ?? {};
      var parent = firststudent['parent'] ?? {};
      var newAdress = data['addresses'];
      if(student.isEmpty ){
        studentText = 'Kein Schüler gefunden';
        personScore = 0.0;
      }else{
        studentText = '${firststudent['lastname'] ?? 'MusterJr'}\n${firststudent['firstname'] ?? 'Max'}'
                      '\n${firststudent['school_class'] ?? '0X'}';
        personId = firststudent['id'];
        if(firststudent['similarity_score'] != null){
          personScore = !isChecked ? firststudent['similarity_score'] : 1.0;
        }
        else{
          personScore = 0.15;
        }
      }
      if(parent.isEmpty){
        parentText = 'Kein Elternteil gefunden';
        parentScore = 0.0;
      }else{
        parentText = '${parent['lastname'] ?? 'Muster'}\n${parent['firstname'] ?? 'John'}\n${parent['phone_number']?? '0000000'}'
                      '\n${parent?['email'] ?? 'jmuster@web.de'}';
        parentId = parent['id'];
        if(parent['similarity_score'] != null){
          parentScore = !isChecked ? parent['similarity_score'] : 1.0;
        }
        else{
          parentScore = 0.15;
        }
      }
      if(newAdress.isEmpty){
        addressText = 'Keine Adresse gefunden';
        addressScore = 0.1;
      }else{
        Map<String,dynamic> firstNewAdress = newAdress[0];
        if(firstNewAdress.isEmpty){
          addressText = 'Keine Adresse gefunden';
          addressScore = 0.1;
        }
        addressText = '${firstNewAdress['street_name'] ?? 'Mstr'}-${firstNewAdress['house_number'] ?? '00'}\n${firstNewAdress['postal_code'] ?? '00000'}'
                      '\nBremen';
        if(firstNewAdress['similarity_score'] != null){
          addressScore = !isChecked ? firstNewAdress['similarity_score'] : 1.0;
        }
        else{
          addressScore = 0.15;
        }
      }
    }
    return {
      'student': studentText,
      'parent': parentText,
      'address': addressText,
    };
  }

  // Methode zum Formatieren der Informationen für AG-Wahl
  Map<String,dynamic> _constructAGText(Map<String, dynamic> data) {
    String agText = '';
    double score = 0.0;
    if(desableDbComparison!){
      agText = '${data['ag_1']?['prediction'] ?? 'label_ag_1'}\n${data['ag_2']?['prediction']?? 'label_ag_2'}\n${data['ag_3']?['prediction'] ?? 'label_ag_3'}';
      if( data['ag_1']?['confidence'] != null && data['ag_2']?['confidence'] != null && data['ag_3']?['confidence'] != null){
        score = (data['ag_1']?['confidence'] ?? 0.15 + data['ag_2']?['confidence'] ?? 0.15 + data['ag_3']?['confidence'] ?? 0.15)/3;
      }
      else{
        score = 0.15;
      } 
      return {'text':agText, 'score':score};
    }else{
      var ag1 = data['ag_1'];
      var ag2 = data['ag_2'];
      var ag3 = data['ag_3'];
      agIds.clear();
        agText = '${ag1[0]?['name'] ?? 'Kein AG Wahl 1'}\n${ag2[0]?['name'] ?? 'Kein AG Wahl 2'}\n${ag3[0]?['name'] ?? 'Kein AG Wahl 3'}';
        if(ag1[0]['similarity_score'] != null && ag2[0]['similarity_score'] != null && ag3[0]['similarity_score'] != null){
          score = (ag1[0]['similarity_score'] + ag2[0]['similarity_score'] + ag3[0]['similarity_score'])/3;
        }
        else{
          score = 0.15;
        }
        agIds.add(ag1[0]?['id'] ?? 0);
        agIds.add(ag2[0]?['id'] ?? 0);
        agIds.add(ag3[0]?['id'] ?? 0);
    }
    print(' ags Ids: ${agIds.toString()} und Score: $score');
    return {'text':agText, 'score':score};
  }

  // Methode zum Erstellen des JSON-Objekts für die richtigen Daten, die gespeichert werden sollen
  // wenn der Benutzer die Informationen bestätigt hat, und der Dokumententyp AD ist
  Map<String, dynamic> buildADChangeResponse(){
    var studentChangeData, parentChangeData, addressChangeData;
    List <String> stdInfo = displayTextStudent!.split('\n');
    List <String> prntInfo = displayTextErzieher!.split('\n');
    List <String> adrInfo = displayTextAdresse!.split('\n');
    List <String> strUndHnr = adrInfo[0].split('-');
    String hNr = strUndHnr[1];
    studentChangeData = {
      'firstname': stdInfo[1],
      'lastname': stdInfo[0],
      'class_name': stdInfo[2],
    };

    
    parentChangeData = {
      'firstname': prntInfo[1],
      'lastname': prntInfo[0],
      'phone_number': prntInfo[2],
      'email': prntInfo[3],
    };

    
    addressChangeData = {
      'street': strUndHnr[0],
      'postal_code': int.parse(adrInfo[1]),
      'house_number': hNr,
    };

    return {
      'student': studentChangeData,
      'parent': parentChangeData,
      'address': addressChangeData,
    };
  }

  // Methode zum Erstellen des JSON-Objekts für die richtigen Daten, die gespeichert werden sollen
  // wenn der Benutzer die Informationen bestätigt hat, und der Dokumententyp AG ist
  Map<String, dynamic> buildAGChangeResponse(){
    List <String> agInfo = displayTextAG!.split('\n');
    List<String> stdInfo = displayTextStudent!.split('\n');
    var studentChangeData = {
      'firstname': stdInfo[1],
      'lastname': stdInfo[0],
      'class_name': stdInfo[2],
    }; 
    return {
      'student': studentChangeData,
      'ags': agInfo,
    };
  }

  // Methode zum Festlegen der Farbe des Randes abhängig vom Similarity_score aus der KI oder backend
  Color _getColorFromScore(double score) {
    if(score == 1.0){
      return Colors.green;
    }
    else if (score > 0.80 && score < 1.0) {
      return Colors.orange;
    } else if (score < 0.80 && score >= 0.5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
