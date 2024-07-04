import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lectorai_frontend/models/adresse.dart';
import 'package:lectorai_frontend/models/schueler.dart';
import 'package:lectorai_frontend/seiten/BlattView/InitialOverlay.dart';
import 'package:lectorai_frontend/seiten/BlattView/OverlayList.dart';
import 'package:lectorai_frontend/seiten/BlattView/SelectableOverlayList.dart';
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
  bool? desableDbComparison, dontSaveChanges;
  final int _currentIndex = 0;
  int? personId, parentId, addressId;
  List<int> agIds = [];
  double? personScore, parentScore, addressScore, agScore;
  Repository repository = Repository();
  List<String> type = ['ad', 'ag'];
  Adresse adresse = Adresse();
  Schueler schueler = Schueler(id: 0,vorname: '',nachname: '');
  
  

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
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
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
      _showOverlay();
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
        title: const Text("Erfasste Schüler Blatt"),
        leading:GestureDetector(
          onTap: () {
            if(isChecked){
              removeFirstOverlay();
              removeSecondOverlay();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
            else{
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
           Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width * 0.1 / 2),
              child: IconButton(
                icon: Icon(Icons.remove_red_eye, size: MediaQuery.of(context).size.width * 0.05),
                onPressed: () 
                {
                    //Navigieren zur ViewImagePage mit dem Byte-Array
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewImagePage(imageBytes: widget.imageBytes, onReturn: _restoreOverlay,),
                        ),
                      ).then((value) => _restoreOverlay());
                      removeFirstOverlay();
                      removeSecondOverlay();
                    
                },
              ),
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
                  onRender: (_pages) {
                    setState(() {});
                  },
                  onViewCreated: (PDFViewController vc) {
                    _controller = vc;
                  },
                  onPageError: (page, e) {
                    print(e);
                  },
                ),
                // Widget zur verhinderung der Interaktion mit dem PDF
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
        var AD_data = _constructADTextInformation(_jsonData);
        var student, newAdress, signature, sig;
        displayTextStudent = AD_data['student'];
        displayTextErzieher = AD_data['parent'];
        displayTextAdresse = AD_data['address'];
        if(!desableDbComparison!){
          newAdress = _jsonData['addresses'];
          addressId = newAdress[0]['id'];
          student = _jsonData['students'];
          var val = _jsonData['signature_box_found'];
          if(!val){
            sig = false;
            signature = 'Not Found';
          }
          else{
            sig = true;
            signature ='Found';
          }
        }
        else{
          var val = _jsonData['signature'];
          if(val == null || val.isEmpty){
            sig = false;
            signature = 'Not Found';
          }
          else{
            sig = true;
            signature ='Found';
          };
        }
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              // Position für Button-Container
              _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, personScore!),
              _iconsOverlay(0.445, 0.68, student, 'erzieher'),
              _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, parentScore!),
              _iconsOverlay(0.547, 0.68, student, 'schueler'),
              _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, addressScore!),
              _iconsOverlay(0.65, 0.68, newAdress, 'addresse'),
              // Add signature box
              _positionedOverlaywithText(
                'Signature: $signature',
                0.5,
                0.04,
                0.81,
                0.195,
                sig ? 1.0 : 0.0,
              ),
            ],
          ),
        );
      } 
      else {
        var student;
        String signature;
        bool sig;
        print('aktuelle no_db value ${desableDbComparison!}');
        if(desableDbComparison!){
          displayTextStudent = '${_jsonData['child_last_name']?['prediction'] ?? 'Muster'}\n${_jsonData['child_first_name']?['prediction'] ?? 'Max'}\n${_jsonData['child_class']?['prediction'] ?? '0X'}';
          personScore = (_jsonData['child_last_name']?['confidence'] ?? 0.0 + _jsonData['child_first_name']?['confidence'] ?? 0.0 + _jsonData['child_class']?['confidence'] ?? 0.0)/3;
          displayTextAG = _constructAGText(_jsonData);
          var val = _jsonData['signature'];
          if(val == null || val.isEmpty){
            sig = false;
            signature = 'Not Found';
          }
          else{
            sig = true;
            signature ='Found';
          };
        }
        else{
          student = _jsonData['students'];
          if(student.isEmpty){
            displayTextStudent = 'Keine Schüler gefunden';
            personScore = 0.0;
          }else{
            Map<String,dynamic> fs = student[0];
            displayTextStudent = '${fs["lastname"]?['value'] ?? 'Muster'}\n${fs['firstname']?['value'] ?? 'Max'}\n${fs['school_class']?['value'] ?? '0X'}';
            personId = fs['id'];
            personScore = fs['similarity_score'] ?? 0.0;
          }
          displayTextAG = _constructAGText(_jsonData); 
          sig = _jsonData['signature_box_found'] ? true : false;
          var val = _jsonData['signature_box_found'];
          if(!val){
            sig = false;
            signature = 'Not Found';
          }
          else{
            sig = true;
            signature ='Found';
          }
        }
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              // Position für Schüler-Daten-Container
              _positionedOverlaywithText(displayTextStudent!,0.7, 0.108, 0.508, 0.1, personScore!),
              // Position für Button-Container
              _iconsOverlay(0.495, 0.675, student, 'schueler'),
              // Position für AG-Container
              _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, agScore!),
              // // Position für Button-Container
               _iconsOverlay(0.61, 0.675, _jsonData, 'ag'),
              // Add signature box
              _positionedOverlaywithText(
                'Signature: $signature',
                0.5,
                0.07,
                0.78,
                0.15,
                sig ? 1.0 : 0.0,
              ),
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
                  displayTextErzieher = selectedItem['text'];
                  personId = selectedItem['id'];
                  print(personId);
                  _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, 0.40);
                } else if (boxname == 'schueler') {
                  displayTextStudent = selectedItem['text'];
                  parentId = selectedItem['id'];
                  print(parentId);
                  _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, 0.40);
                } else if (boxname == 'addresse') {
                  displayTextAdresse = selectedItem['text'];
                  addressId = selectedItem['id'];
                  print(addressId);
                  _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, 0.40);
                } else if (boxname == 'ag') {
                  print(agIds.toString());
                  displayTextAG = selectedItem['text'];
                  _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, 0.40);
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
                        double topMultiplicator, double leftMultiplicator,double score) {
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
            icon: Icon(Icons.edit,
                color: Color(0xff3d7c88)), // Button-Farbe ändern
            onPressed: () {
              _showSecondOverlay(data, infoBox);
            },
          ),
          IconButton(
            icon: Icon(Icons.check,
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
                }
                print('Change Daten zu speichern: \n ${_changeData.toString()}');
              });
              _showOverlay();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBox(
      String text, double width, double height, Color color, double score) {
    return  Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color:  color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isChecked? Colors.green : _getColorFromScore(score),
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

  Widget buildSaveChangeButton() {
    return  Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          onPressed: () async {
            if(widget.demoModus!){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo-Modus Änderungen gespeichert'),
                    duration: Duration(seconds: 5),
                  ),
              );
            }
            else{
              if(dontSaveChanges!){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Änderungen übertragen deaktiviert'),
                    duration: Duration(seconds: 5),
                  ),
              );
              }
              else{
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
        personScore = (childLastNameConfidence + childFirstNameConfidence + childClassConfidence) / 3;

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
        parentScore = (parentLastNameConfidence + parentFirstNameConfidence + parentPhoneConfidence + parentEmailConfidence) / 4;

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
        addressScore = (addressStreetNameConfidence + addressHouseNumberConfidence + addressZipConfidence + addressCityConfidence) / 4;

      }
    }else{
      var student = data['students'];
      Map<String,dynamic> firststudent = student?[_currentIndex] ?? {};
      var parent = firststudent?['parent'] ?? {};
      var newAdress = data['addresses'];
      if(student.isEmpty ){
        studentText = 'Kein Schüler gefunden';
        personScore = 0.0;
      }else{
        studentText = '${firststudent['lastname']?['value'] ?? 'MusterJr'}\n${firststudent['firstname']?['value'] ?? 'Max'}'+
                      '\n${firststudent['school_class']?['value'] ?? '0X'}';
        personId = firststudent['id'];
        personScore = firststudent?['similarity_score'] ?? 0.0;
      }
      if(parent.isEmpty){
        parentText = 'Kein Elternteil gefunden';
        parentScore = 0.0;
      }else{
        parentText = '${parent?['lastname']?['value'] ?? 'Muster'}\n${parent?['firstname']?['value'] ?? 'John'}\n${parent?['phone_number']?['value'] ?? '0000000'}'+
                      '\n${parent?['email']?['value'] ?? 'jmuster@web.de'}';
        parentId = parent['id'];
        parentScore = parent?['similarity_score'] ?? 0.0;
      }
      if(newAdress.isEmpty){
        addressText = 'Keine Adresse gefunden';
        addressScore = 0.0;
      }else{
        Map<String,dynamic> firstNewAdress = newAdress[0];
        addressText = '${firstNewAdress['street_name']?['value'] ?? 'Mstr'} ${firstNewAdress['house_number'] ?? '00'}\n${firstNewAdress['location']?['postal_code'] ?? '00000'}'
                      '\n${firstNewAdress['location']?['location_name'] ?? 'MusterOrt'}';
        addressScore = (firstNewAdress["similarity_score"] ?? 0 + firstNewAdress["similarity_score"] ?? 0)/2;
        addressId = firstNewAdress['id'];
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
        agText = '${ag1?[0]['ag_name']?['value'] ?? 'Wahl 1'}\n${ag2?[0]['ag_name']?['value'] ?? 'Wahl 2'}\n${ag3?[0]['ag_name']?['value'] ?? 'Wahl 3'}';
        agScore = (ag1?[0]['ag_name']?['similarity_score'] ?? 0 + ag2?[0]['ag_name']?['similarity_score'] ?? 0 + ag3?[0]['ag_name']?['similarity_score'] ?? 0)/3;
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
    List <String> strUndHnr = adrInfo[0].split(' ');
    int hNr = int.parse(strUndHnr[1]);
    studentChangeData = {
      'firstname': stdInfo[1],
      'lastname': stdInfo[0],
      'school_class': stdInfo[2],
    };

    
    parentChangeData = {
      'firstname': prntInfo[1],
      'lastname': prntInfo[0],
      'phone_number': prntInfo[2],
      'email': prntInfo[3],
    };

    
    addressChangeData = {
      'street_name': adrInfo[0],
      'postal_code': adrInfo[2],
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
      'school_class': stdInfo[2],
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
