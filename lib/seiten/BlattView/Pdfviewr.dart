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

  final String authToken;
  final Uint8List imageBytes;
  final bool demoModus;

  @override
  PdfViwerState createState() => PdfViwerState();
}

class PdfViwerState extends State<PdfViwer>  with WidgetsBindingObserver {
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
  bool? desableDbComparison, dontSaveChanges;
  final int _currentIndex = 0;
  int? personId, parentId, addressId;
  List<int> agIds = [];
  double? personScore, parentScore, addressScore, agScore;
  Repository repository = Repository();
  List<String> type = ['ad', 'ag'];
  Color? personColor, parentColor, addressColor, agColor, signatureColor;
  
  

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
    fetchDataAndSetting();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay();
    });
  }

  Future<void> fetchDataAndSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    desableDbComparison = prefs.getBool('desableDbComparison');
    dontSaveChanges = prefs.getBool('dontSaveChanges');
    print('Aktuelle no_db value: $desableDbComparison');
    Map<String, dynamic> responseJson;
    if(widget.demoModus){
      var str = getRandomDemoDocType(type);
      final String response = await rootBundle.loadString('assets/Daten/${str}_sample.json');
      responseJson = json.decode(response);
      docType = responseJson['doc_type'];
    }
    else{
      //responseJson = await repository.testADOverlay(widget.authToken);//sendImage(widget.authToken, widget.imageBytes);
      responseJson = await repository.sendImage(widget.authToken, widget.imageBytes, desableDbComparison!);
      docType = desableDbComparison!? responseJson['doctype'] : responseJson['doc_type'];
    }
    
    
    var f = await getFileFromAsset("assets/Doc/$docType.pdf");
    setState(() {
      _jsonData = responseJson;
      path = f.path;
      _showOverlay();
    });

    print(path);
  }



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

  String getRandomDemoDocType(List<String> list) {
    final random = Random();
    int index = random.nextInt(list.length);
    return list[index];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    if(isChecked){
      _overlayEntry = _changeOverlayBorder(Colors.green);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        isOverLayVisible = true;
      });
    }
    else{
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        isOverLayVisible = true;
      });
    }
  }

   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called when the widget’s dependencies change.
    // Handle the overlay display logic if needed.
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

  void _showSecondOverlay(var data , String boxname) {
    _secondOverlay = _createOverlayList(context, data, boxname);
    Overlay.of(context).insert(_secondOverlay!);
  }

  void removeFirstOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
    });
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

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
              title: const Text("Erfasste Informationen"),
              leading: GestureDetector(
                  onTap: () {
                      if (isChecked) {
                          isOverLayVisible = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          removeFirstOverlay();
                          removeSecondOverlay();
                      } else {
                          isOverLayVisible = false;
                          removeFirstOverlay();
                          removeSecondOverlay();
                          Navigator.pop(context);
                      }
                  },
                  child: Container(
                      padding: const EdgeInsets.all(15.0),
                      height: 10,
                      child: Image.asset('assets/Bilder/_.png', color: Colors.black, scale: 1.0,),
                  )
              ),
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
                      // Widget zur Verhinderung der Interaktion mit dem PDF
                      Positioned.fill(
                          child: GestureDetector(
                              onScaleStart: (_) {},
                              onScaleUpdate: (_) {},
                              onScaleEnd: (_) {},
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
      );
  }

  OverlayEntry _createOverlayEntry() {
    try {
      print(docType);
      if (docType == 'Adresse' || docType == 'AD') {
        var adData = _constructADTextInformation(_jsonData);
        var student, newAdress, signature;
        displayTextStudent = adData['student'];
        displayTextErzieher = adData['parent'];
        displayTextAdresse = adData['address'];
        personColor = _getColorFromScore(personScore!);
        parentColor = _getColorFromScore(parentScore!);
        addressColor = _getColorFromScore(addressScore!);
        print('aktuelle no_db value ${desableDbComparison!}');
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
          var val = _jsonData['signature'];
          if(val == null || val.isEmpty){
            isSigned = false;
            signature = 'Not Found';
          }
          else{
            isSigned = true;
            signature ='Found';
          }
          signatureColor = isSigned ? Colors.green : Colors.red;
        }
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              Visibility(
                visible: isOverLayVisible,
                child: Stack(
                  children: [
                    _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, personColor!),
                    _iconsOverlay(0.445, 0.67, student, 'erzieher'),
                    _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, parentColor!),
                    _iconsOverlay(0.547, 0.67, student, 'schueler'),
                    _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, addressColor!),
                    _iconsOverlay(0.65, 0.67, newAdress, 'addresse'),
                    _positionedOverlaywithText('Signature: $signature', 0.5, 0.04, 0.81, 0.195, signatureColor!),
                  ],
                ),

              ),
              // Position für Button-Container
              // _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, personColor!),
              // _iconsOverlay(0.445, 0.67, student, 'erzieher'),
              // _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, parentColor!),
              // _iconsOverlay(0.547, 0.67, student, 'schueler'),
              // _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, addressColor!),
              // _iconsOverlay(0.65, 0.67, newAdress, 'addresse'),
              // // Add signature box
              // _positionedOverlaywithText(
              //   'Signature: $signature',
              //   0.5,
              //   0.04,
              //   0.81,
              //   0.195,
              //   signatureColor!,
              // ),
            ],
          ),
        );
      } 
      else {
        var student;
        String signature;
        print('aktuelle no_db value ${desableDbComparison!}');
        if(desableDbComparison!){
          displayTextStudent = '${_jsonData['child_last_name']?['prediction'] ?? 'Muster'}\n${_jsonData['child_first_name']?['prediction'] ?? 'Max'}\n${_jsonData['child_class']?['prediction'] ?? '0X'}';
          personScore = !isChecked ? (_jsonData['child_last_name']?['confidence'] ?? 0.0 + _jsonData['child_first_name']?['confidence'] ?? 0.0 + _jsonData['child_class']?['confidence'] ?? 0.0)/3 : 1.0;
          displayTextAG = _constructAGText(_jsonData);
          var val = _jsonData['signature'];
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
            personScore =  fs['similarity_score'] ??  0.0;
            personColor = isChecked? Colors.green : _getColorFromScore(personScore!);
          }
          displayTextAG = _constructAGText(_jsonData); 
          agColor = isChecked? Colors.green : _getColorFromScore(agScore!);
          //isSigned = _jsonData['signature'] ? true : false;
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
                    _positionedOverlaywithText(
                      'Signature: $signature',
                      0.5,
                      0.07,
                      0.78,
                      0.15,
                      signatureColor!,
                    ),
                  ],
                ),

              ),
              // // Position für Schüler-Daten-Container
              // _positionedOverlaywithText(displayTextStudent!,0.7, 0.108, 0.508, 0.1, personColor!),
              // // Position für Button-Container
              // _iconsOverlay(0.495, 0.66, student, 'schueler'),
              // // Position für AG-Container
              // _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, agColor!),
              // // // Position für Button-Container
              //  _iconsOverlay(0.61, 0.66, _jsonData, 'ag'),
              // // Add signature box
              // _positionedOverlaywithText(
              //   'Signature: $signature',
              //   0.5,
              //   0.07,
              //   0.78,
              //   0.15,
              //   signatureColor!,
              // ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Fehler beim Erstellen des Overlays: $e');
      return OverlayEntry(builder: (context) => Container());
    }
  }

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
              removeSecondOverlay();
            }, boxname: boxname,
            isDemoModus: widget.demoModus,
          ),
        ),
      ),
    );
  }


  Widget _positionedOverlaywithText(String text, double widthMultiplicator, double heightMultiplicator, 
                        double topMultiplicator, double leftMultiplicator,Color score) {
    return Positioned(
      width: MediaQuery.of(context).size.width * widthMultiplicator,
      height: MediaQuery.of(context).size.height * heightMultiplicator,
      top: MediaQuery.of(context).size.height * topMultiplicator,
      left: MediaQuery.of(context).size.width * leftMultiplicator,
      child: _buildOverlayBox(
        text,
        220,
        80,
        Colors.white.withOpacity(0.3),
        score,
      ),
    );
  }


  Widget _iconsOverlay(double topMultiplicator, double leftMultiplicator, var data, String infoBox) {
    return Positioned(
      width: 180,
      height: 100,
      top: MediaQuery.of(context).size.height * topMultiplicator,
      left: MediaQuery.of(context).size.width * leftMultiplicator,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit,
                color: Color(0xff3d7c88)), // Button-Farbe ändern
            onPressed: () {
              _showSecondOverlay(data, infoBox);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check,
                color: Colors.green), // Button-Farbe ändern
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
                  hideSaveButton = false;
                  if(docType == 'Adresse' || docType == 'AD'){
                    _changeData = buildADChangeResponse();
                  }
                  else{
                    _changeData = buildAGChangeResponse();
                  }
                  _showOverlay();
                }
                print('Change Daten zu speichern: \n ${_changeData.toString()}');
              });
            },
          ),
        ],
      ),
    );
  }

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
            fit: BoxFit
                .scaleDown, // FittedBox hinzugefügt, um den Text responsiv zu machen
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
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

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
        studentText = '${data['child_last_name']?['prediction'] ?? 'Doe'}\n'
                            '${data['child_first_name']?['prediction'] ?? 'Max'}\n'
                            '${data['child_class']?['prediction'] ?? '0X'}';

        // Berechnung des gesamten Scores für den Schüler
        num childLastNameConfidence = data['child_last_name']?['confidence'] ?? 0;
        num childFirstNameConfidence = data['child_first_name']?['confidence'] ?? 0;
        num childClassConfidence = data['child_class']?['confidence'] ?? 0;
        personScore = !isChecked ? (childLastNameConfidence + childFirstNameConfidence + childClassConfidence) / 3 : 1.0;

        // Sicherstellen, dass alle benötigten Felder nicht null sind und einen Standardwert festlegen
        parentText = '${data['parent_last_name']?['prediction'] ?? 'Doe'}\n'
                            '${data['parent_first_name']?['prediction'] ?? 'John'}\n'
                            '${data['parent_phone']?['prediction'] ?? '0000000'}\n'
                            '${data['parent_email']?['prediction'] ?? 'muster@web.de'}';

        // Berechnung des Scores für die Eltern
        num parentLastNameConfidence = data['parent_last_name']?['confidence'] ?? 0;
        num parentFirstNameConfidence = data['parent_first_name']?['confidence'] ?? 0;
        num parentPhoneConfidence = data['parent_phone']?['confidence'] ?? 0;
        num parentEmailConfidence = data['parent_email']?['confidence'] ?? 0;
        parentScore = !isChecked ? (parentLastNameConfidence + parentFirstNameConfidence + parentPhoneConfidence + parentEmailConfidence) / 4 : 1.0;

        // Sicherstellen, dass alle benötigten Felder nicht null sind und einen Standardwert festlegen
        addressText = '${data['address_street_name']?['prediction'] ?? 'Musterstr'} '
                            '${data['address_house_number']?['prediction'] ?? '00'}\n'
                            '${data['address_zip']?['prediction'] ?? '00000'}\n'
                            '${data['address_city']?['prediction'] ?? 'Bremen'}';

        // Berechnung des Scores für die Adresse
        num addressStreetNameConfidence = data['address_street_name']?['confidence'] ?? 0;
        num addressHouseNumberConfidence = data['address_house_number']?['confidence'] ?? 0;
        num addressZipConfidence = data['address_zip']?['confidence'] ?? 0;
        num addressCityConfidence = data['address_city']?['confidence'] ?? 0;
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
        personScore = !isChecked ? firststudent['similarity_score'] ?? 0.0 : 1.0;
      }
      if(parent.isEmpty){
        parentText = 'Kein Elternteil gefunden';
        parentScore = 0.0;
      }else{
        parentText = '${parent['lastname'] ?? 'Muster'}\n${parent['firstname'] ?? 'John'}\n${parent['phone_number']?? '0000000'}'
                      '\n${parent?['email'] ?? 'jmuster@web.de'}';
        parentId = parent['id'];
        parentScore = !isChecked ? parent['similarity_score'] ?? 0.0 : 1.0;
      }
      if(newAdress.isEmpty){
        addressText = 'Keine Adresse gefunden';
        addressScore = 0.0;
      }else{
        Map<String,dynamic> firstNewAdress = newAdress[0];
        addressText = '${firstNewAdress['street_name'] ?? 'Mstr'}-${firstNewAdress['house_number'] ?? '00'}\n${firstNewAdress['postal_code'] ?? '00000'}'
                      '\nBremen';
        addressScore = !isChecked ? (firstNewAdress["similarity_score"] ?? 0 + firstNewAdress["similarity_score"] ?? 0)/2 : 1.0;
      }
    }
    return {
      'student': studentText,
      'parent': parentText,
      'address': addressText,
    };
  }

  String _constructAGText(Map<String, dynamic> data) {
    String agText = '';
    if(desableDbComparison!){
      agText = '${data['ag_1']?['prediction'] ?? 'label_ag_1'}\n${data['ag_2']?['prediction']?? 'label_ag_2'}\n${data['ag_3']?['prediction'] ?? 'label_ag_3'}';
      agScore = (data['ag_1']?['confidence'] ?? 0.0 + data['ag_2']?['confidence'] ?? 0.0 + data['ag_3']?['confidence'] ?? 0.0)/3;
      return agText;
    }else{
      var ag1 = data['ag_1'];
      var ag2 = data['ag_2'];
      var ag3 = data['ag_3'];
      agIds.clear();
        agText = '${ag1?[0]['name'] ?? 'Kein Wahl 1'}\n${ag2?[0]['name'] ?? 'Kein Wahl 2'}\n${ag3?[0]['name'] ?? 'Kein Wahl 3'}';
        agScore = !isChecked ? (ag1?[0]['similarity_score'] ?? 0 + ag2?[0]['similarity_score'] ?? 0 + ag3?[0]['similarity_score'] ?? 0)/3 : 1.0;
        agIds.add(ag1?[0]['id'] ?? 0);
        agIds.add(ag2?[0]['id'] ?? 0);
        agIds.add(ag3?[0]['id'] ?? 0);
    }
    print(agIds.toString());
    return agText;
  }

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
