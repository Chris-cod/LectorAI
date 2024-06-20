import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lectorai_frontend/seiten/BlattView/OverlayList.dart';
import 'package:lectorai_frontend/seiten/CamerPage/ViewImagePage.dart';
import 'package:lectorai_frontend/services/repository.dart';
import 'package:path_provider/path_provider.dart';

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
  late PDFViewController _controller;
  String? path, displayTextErzieher, displayTextStudent, displayTextAdresse, displayTextAG;
  Map<String, dynamic> _jsonData = {};
  bool dataLoaded = false;
  bool personIsChecked = false;
  bool parentIsChecked = false;
  bool addressIsChecked = false;
  bool agIsChecked = false;
  bool isChecked = false;
  int _currentIndex = 0;
  int? person_id, parent_id, address_id;
  List<int> ag_id = [];
  double? person_score, parent_score, address_score, ag_score;
  Repository repository = Repository();
  List<String> type = ['ad', 'ag'];
  

  @override
  void initState() {
    super.initState();
    readJson().then((value) => setState(() {
          _showOverlay(context);
    }));
  }

  Future<void> readJson() async {
    Map<String, dynamic> responseJson;
    if(widget.demoModus){
      String doc_type = getRandomDemoDocType(type);
      final String response = await rootBundle.loadString('assets/Daten/${doc_type}_sample.json');
      responseJson = json.decode(response);
    }
    else{
      //responseJson = await repository.testADOverlay(widget.authToken);//sendImage(widget.authToken, widget.imageBytes);
      responseJson = await repository.sendImage(widget.authToken, widget.imageBytes);
    }
    
    
    var f = await getFileFromAsset("assets/Doc/${responseJson['doc_type']}.pdf");
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

  void _showOverlay(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(context);
    if (_overlayEntry != null) {
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  void _showSecondOverlay(var data , String boxname) {
    _secondOverlay = _createOverlayList(context, data, boxname);
    Overlay.of(context)?.insert(_secondOverlay!);
  }

  void removeFirstOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
                  removeFirstOverlay();
                  removeSecondOverlay();
                  //Navigieren zur ViewImagePage mit dem Byte-Array
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ViewImagePage(imageBytes: widget.imageBytes)
                  ));
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
      print(_jsonData['doc_type']);
      if (_jsonData['doc_type'] == 'Adresse' || _jsonData['doc_type'] == 'AD') {
        var student = _jsonData['students'];
        Map<String,dynamic> firststudent = student[_currentIndex];
        displayTextStudent = '${firststudent['firstname']['value']}\n${firststudent['lastname']['value']}\n${firststudent['school_class']['value']}';
        person_id = firststudent['id'];
        person_score = firststudent['similarity_score'];
        var parent = firststudent['parent'];
        displayTextErzieher = '${parent['firstname']['value']}\n${parent['lastname']['value']}\n${parent['phone_number']['value']}\n${parent['email']['value']}';
        parent_id = parent['id'];
        parent_score = parent['similarity_score'];
        var newAdress = _jsonData['addresses'];
        Map<String,dynamic> firstNewAdress = newAdress[0];
        displayTextAdresse = '${firstNewAdress['street_name']['value']} ${firstNewAdress['house_number']}\n${firstNewAdress['location']['location_name']}\n${firstNewAdress['location']['postal_code']}';
        address_score = (firstNewAdress["similarity_score"] + firstNewAdress["similarity_score"])/2;
        address_id = firstNewAdress['id'];
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              // Position für Button-Container
              _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, person_score!),
              _iconsOverlay(0.445, 0.68, student, 'erzieher'),
              _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, parent_score!),
              _iconsOverlay(0.547, 0.68, student, 'schueler'),
              _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, address_score!),
              _iconsOverlay(0.65, 0.68, newAdress, 'addresse'),
            ],
          ),
        );
      } else {
        List<dynamic> student = _jsonData['students'];
        Map<String,dynamic> fs = student[0];
        displayTextStudent = '${fs["firstname"]['value']}\n${fs['lastname']['value']}\n${fs['school_class']['value']}';
        person_id = fs['id'];
        person_score = fs['similarity_score'];
        var ag1 = _jsonData['ag_1'];
        var ag2 = _jsonData['ag_2'];
        var ag3 = _jsonData['ag_3'];
        displayTextAG = '${ag1[0]['ag_name']['value']}\n${ag2[0]['ag_name']['value']}\n${ag3[0]['ag_name']['value']}';
        ag_score = (ag1[0]['ag_name']['similarity_score'] + ag2[0]['ag_name']['similarity_score'] + ag3[0]['ag_name']['similarity_score'])/3;
        ag_id.add(ag1[0]['id']);
        ag_id.add(ag2[0]['id']);
        ag_id.add(ag3[0]['id']);
         
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              // Position für Schüler-Daten-Container
              _positionedOverlaywithText(displayTextStudent!,0.7, 0.108, 0.508, 0.1, person_score!),
              // Position für Button-Container
              _iconsOverlay(0.495, 0.675, student, 'schueler'),
              // Position für AG-Container
              _positionedOverlaywithText(displayTextAG!, 0.7, 0.108, 0.62, 0.1, ag_score!),
              // // Position für Button-Container
               _iconsOverlay(0.61, 0.675, _jsonData, 'ag')
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
                  person_id = selectedItem['id'];
                  print(person_id);
                  _positionedOverlaywithText(displayTextErzieher!, 0.7, 0.104, 0.465, 0.1, 0.40);
                } else if (boxname == 'schueler') {
                  displayTextStudent = selectedItem['text'];
                  parent_id = selectedItem['id'];
                  print(parent_id);
                  _positionedOverlaywithText(displayTextStudent!, 0.7, 0.101, 0.57, 0.1, 0.40);
                } else if (boxname == 'addresse') {
                  displayTextAdresse = selectedItem['text'];
                  address_id = selectedItem['id'];
                  print(address_id);
                  _positionedOverlaywithText(displayTextAdresse!, 0.7, 0.088, 0.675, 0.1, 0.40);
                } else if (boxname == 'ag') {
                  ag_id = selectedItem['id'];
                  print(ag_id.toString());
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
                }
              });
              _showOverlay(context);
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
          onPressed: () {
            //Hier die Daten speichern
          },
          child: const Text('Änderungen speichern'),
        ),
      );
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
