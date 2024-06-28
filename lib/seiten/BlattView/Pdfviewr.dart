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

class PdfViwerState extends State<PdfViwer> {
  int? currentPage = 0;
  bool pdfReady = false;
  OverlayEntry? _overlayEntry, _secondOverlay;
  // ignore: unused_field
  late PDFViewController _controller;
  String? path, displayTextErzieher, displayTextStudent, displayTextAdresse, displayTextAG, docType;
  Map<String, dynamic> _jsonData = {};
  Map<String, dynamic> _changeData = {};
  bool dataLoaded = false;
  bool personIsChecked = false;
  bool parentIsChecked = false;
  bool addressIsChecked = false;
  bool agIsChecked = false;
  bool isChecked = false;
  bool isSaved = false;
  bool isOverlayVisible = false;
  bool? desableDbComparison, dontSaveChanges;
  final int _currentIndex = 0;
  int? personId, parentId, addressId;
  List<int> agIds = [];
  double? personScore, parentScore, addressScore, agScore;
  Repository repository = Repository();
  List<String> type = ['ad', 'ag'];
  
  

  @override
  void initState() {
    super.initState();
    fetchDataAndSetting().then((value) => setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOverlay();
        });
    }));
  }

  Future<void> fetchDataAndSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    desableDbComparison = prefs.getBool('desableDbComparison');
    dontSaveChanges = prefs.getBool('dontSaveChanges');
    Map<String, dynamic> responseJson;
    if(widget.demoModus){
      docType = getRandomDemoDocType(type);
      final String response = await rootBundle.loadString('assets/Daten/${docType}_sample.json');
      responseJson = json.decode(response);
    }
    else{
      //responseJson = await repository.testADOverlay(widget.authToken);//sendImage(widget.authToken, widget.imageBytes);
      responseJson = await repository.sendImage(widget.authToken, widget.imageBytes, desableDbComparison!);
    }
    
    docType = desableDbComparison!? responseJson['doctype'] : responseJson['doc_type'];
    var f = await getFileFromAsset("assets/Doc/$docType.pdf");
    setState(() {
      _jsonData = responseJson;
      path = f.path;
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
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(context);
    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
      setState(() {
        isOverlayVisible = true;
      });
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
      isOverlayVisible = false;
    });
  }

  void removeSecondOverlay() {
    _secondOverlay?.remove();
    _secondOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Erfasste Schüler Blatt"),
        leading:GestureDetector(
          onTap: () {
            removeFirstOverlay();
            removeSecondOverlay();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            height: 10,
            child: Image.asset('assets/Bilder/_.png', color: Colors.black, scale: 1.0,),
          )
          
        ),
        actions: [
          Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width * 0.1 / 2),
              child: IconButton(
                icon: Icon(Icons.remove_red_eye, size: MediaQuery.of(context).size.width * 0.05),
                onPressed: () 
                {
                  if(isOverlayVisible){
                    removeFirstOverlay();
                      removeSecondOverlay();
                    //Navigieren zur ViewImagePage mit dem Byte-Array
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ViewImagePage(imageBytes: widget.imageBytes)
                    ));
                  }
                },
              ),
            ),
        ],
      ),
      body: path != null
          ? Stack(
              children: [
                PDFView(
                  filePath: path,
                  enableSwipe: false,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  pageSnap: false,
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
                if (isChecked)
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

  OverlayEntry _createOverlayEntry(BuildContext context) {
    try {
      print(docType);
      if (docType == 'Adresse' || docType == 'AD') {
        var student = _jsonData['students'];
        Map<String,dynamic> firststudent = student[_currentIndex];
        displayTextStudent = '${firststudent['firstname']['value']}\n${firststudent['lastname']['value']}\n${firststudent['school_class']['value']}';
        personId = firststudent['id'];
        personScore = firststudent['similarity_score'];
        var parent = firststudent['parent'];
        displayTextErzieher = '${parent['firstname']['value']}\n${parent['lastname']['value']}\n${parent['phone_number']['value']}\n${parent['email']['value']}';
        parentId = parent['id'];
        parentScore = parent['similarity_score'];
        var newAdress = _jsonData['addresses'];
        Map<String,dynamic> firstNewAdress = newAdress[0];
        displayTextAdresse = '${firstNewAdress['street_name']['value']} ${firstNewAdress['house_number']}\n${firstNewAdress['location']['location_name']}\n${firstNewAdress['location']['postal_code']}';
        addressScore = (firstNewAdress["similarity_score"] + firstNewAdress["similarity_score"])/2;
        addressId = firstNewAdress['id'];
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
                'Signature: ${_jsonData['signature_box_found'] ? "Found" : "Not Found"}',
                0.5,
                0.07,
                0.78,
                0.15,
                _jsonData['signature_box_found'] ? 1.0 : 0.0,
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
          displayTextStudent = '${_jsonData['child_last_name']['prediction']}\n${_jsonData['child_first_name']['prediction']}\n${_jsonData['child_class']['prediction']}';
          personScore = (_jsonData['child_last_name']['confidence'] + _jsonData['child_first_name']['confidence'] + _jsonData['child_class']['confidence'])/3;
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
          Map<String,dynamic> fs = student[0];
          displayTextStudent = '${fs["firstname"]['value']}\n${fs['lastname']['value']}\n${fs['school_class']['value']}';
          print(displayTextStudent);
          personId = fs['id'];
          personScore = fs['similarity_score'];
          displayTextAG = _constructAGText(_jsonData); 
          sig = _jsonData['signature_box_found'] ? true : false;
          var val = _jsonData['signature_box_found'];
          if(val == null || val.isEmpty){
            sig = false;
            signature = 'Not Found';
          }
          else{
            sig = true;
            signature ='Found';
          }
        }
        
        print(displayTextAG);
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
                  if(docType == 'Adresse' || docType == 'AD'){
                    _changeData = {
                      'doc_type': docType,
                      'person_id': personId,
                      'parent_id': parentId,
                      'address_id': addressId,
                    };
                  }
                  else{
                    _changeData = {
                      'doc_type': docType,
                      'person_id': personId,
                      'ags': agIds,
                    };
                  }
                }
              });
              _showOverlay();
              print(_changeData.toString());
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
            if(dontSaveChanges!){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Änderungen übertragen deaktiviert'),
                    duration: Duration(seconds: 4),
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
                    duration: Duration(seconds: 4),
                  ),
                );
              }
              else{
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fehler beim Speichern der Änderungen'),
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            }
            
            setState(() {
              isChecked = false;
            });
            //Hier die Daten speichern
          },
          child: const Text('Änderungen speichern'),
        ),
      );
  }

  String _constructAGText(Map<String, dynamic> data) {
    String agText = '';
    if(desableDbComparison!){
      agText = '${data['ag_1']['prediction']}\n${data['ag_2']['prediction']}\n${data['ag_3']['prediction']}';
      agScore = (data['ag_1']['confidence'] + data['ag_2']['confidence'] + data['ag_3']['confidence'])/3;
      return agText;
    }else{
      var ag1 = data['ag_1'];
      var ag2 = data['ag_2'];
      var ag3 = data['ag_3'];
      agIds.clear();
      if(ag1.isNotEmpty && ag2.isNotEmpty && ag3.isNotEmpty){
        agText = '${ag1[0]['ag_name']['value']}\n${ag2[0]['ag_name']['value']}\n${ag3[0]['ag_name']['value']}';
        agScore = (ag1[0]['ag_name']['similarity_score'] + ag2[0]['ag_name']['similarity_score'] + ag3[0]['ag_name']['similarity_score'])/3;
        agIds.add(ag1[0]['id']);
        agIds.add(ag2[0]['id']);
        agIds.add(ag3[0]['id']);
      }
      else {
        if(ag1.isNotEmpty && ag2.isNotEmpty  && ag3.isEmpty){
            agText = '${ag1[0]['ag_name']['value']}\n${ag2[0]['ag_name']['value']}\n';
            agScore = (ag1[0]['ag_name']['similarity_score'] + ag2[0]['ag_name']['similarity_score'])/2;
            agIds.add(ag1[0]['id']);
            agIds.add(ag2[0]['id']);
        }
        else if(ag1.isEmpty && ag2.isNotEmpty  && ag3.isNotEmpty){
          agText = ' \n${ag2[0]['ag_name']['value']}\n${ag3[0]['ag_name']['value']}';
          agScore = (ag2[0]['ag_name']['similarity_score'] + ag3[0]['ag_name']['similarity_score'])/2;
          agIds.add(ag2[0]['id']);
          agIds.add(ag3[0]['id']);
        }
        else if(ag1.isNotEmpty && ag2.isEmpty  && ag3.isNotEmpty){
          agText = '${ag1[0]['ag_name']['value']}\n \n${ag3[0]['ag_name']['value']}';
          agScore = (ag1[0]['ag_name']['similarity_score'] + ag3[0]['ag_name']['similarity_score'])/2;
          agIds.add(ag1[0]['id']);
          agIds.add(ag3[0]['id']);
        }
        else if(ag1.isNotEmpty && ag2.isEmpty  && ag3.isEmpty){
          agText = '${ag1[0]['ag_name']['value']}';
          agScore = ag1[0]['ag_name']['similarity_score'];
          agIds.add(ag1[0]['id']);
        }
        else if(ag1.isEmpty && ag2.isNotEmpty  && ag3.isEmpty){
          agText = '\n${ag2[0]['ag_name']['value']}';
          agScore = ag2[0]['ag_name']['similarity_score'];
          agIds.add(ag2[0]['id']);
        }
        else if(ag1.isEmpty && ag2.isEmpty  && ag3.isNotEmpty){
          agText = '\n\n${ag3[0]['ag_name']['value']}';
          agScore = ag3[0]['ag_name']['similarity_score'];
          agIds.add(ag3[0]['id']);
        }
        else{
          agText = 'Kein Ags';
          agScore = 0.0;
        }
      }
    }
    print(agIds.toString());
    return agText;
  }

  Color _getColorFromScore(double score) {
    if (score >= 0.9) {
      return Colors.green;
    } else if (score >= 0.75 && score < 0.9) {
      return Colors.orange;
    } else if (score < 0.75 && score >= 0.5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
