import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:lectorai_frontend/seiten/BlattView/OverlayList.dart';
import 'package:lectorai_frontend/seiten/CamerPage/ViewImagePage.dart';
import 'package:lectorai_frontend/services/repository.dart';
import 'package:path_provider/path_provider.dart';

class PdfViwer extends StatefulWidget {
  const PdfViwer({super.key, required this.authToken, required this.imageBytes});

  final String authToken;
  final Uint8List imageBytes;

  @override
  PdfViwerState createState() => PdfViwerState();
}

class PdfViwerState extends State<PdfViwer> {
  int? currentPage = 0;
  bool pdfReady = false;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _secondOverlay;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  String? path, displayText;
  Map<String, dynamic> _jsonData = {};
  bool dataLoaded = false;
  int _currentIndex = 0;
  Repository repository = Repository();
  

  @override
  void initState() {
    super.initState();
    readJson().then((value) => setState(() {
          _showOverlay(context);
    }));
  }

  Future<void> readJson() async {
    //final String response =await rootBundle.loadString('assets/Daten/ag_sample.json');
    var responseJson = await repository.sendImage(widget.authToken, widget.imageBytes);
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

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = _createOverlayEntry(context);
    if (_overlayEntry != null) {
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  void _showSecondOverlay(var data , String boxname) {
    _secondOverlay = _createOverlayList(context, data, boxname);
    Overlay.of(context)?.insert(_secondOverlay!);
  }

  void removeSecondOverlay() {
    _secondOverlay?.remove();
    _secondOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erfasste Schüler Blatt"),
        actions: [
          Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: (MediaQuery.of(context).size.width / 2) - (MediaQuery.of(context).size.width * 0.1 / 2),
              child: IconButton(
                icon: Icon(Icons.remove_red_eye, size: MediaQuery.of(context).size.width * 0.1),
                onPressed: () 
                {
                  // Navigieren zur ViewImagePage mit dem Byte-Array
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
                    _controller.complete(vc);
                  },
                  onPageError: (page, e) {
                    print(e);
                  },
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    try {
      print(_jsonData['doc_type']);
      if (_jsonData['doc_type'] == 'Adresse') {
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              _positionedOverlaywithText('test', 0.7, 0.108, 0.508, 0.1, 0.40),
              // Position für Button-Container
              _iconsOverlay(0.508, 0.76, 'student', 'studentBox'),
            ],
          ),
        );
      } else {
        List<dynamic> student = _jsonData['students'];
        Map<String,dynamic> fs = student[0];
        List<dynamic> ags = _jsonData['AGS'];
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              // Position für Schüler-Daten-Container
              _positionedOverlaywithText('${fs["nachname"]['value']}\n${fs['vorname']['value']}\n${fs['class']['value']}', 
                0.7, 0.108, 0.508, 0.1, fs['similarityScorePerson']),
              // Position für Button-Container
              _iconsOverlay(0.508, 0.8, student, 'schueler'),
              // Position für AG-Container
              _positionedOverlaywithText('${ags[0]['Ag_name']['value']}\n${ags[1]['Ag_name']['value']}\nChor', 
               0.7, 0.108, 0.62, 0.1, ags[0]['Ag_name']['score']),
              // Position für Button-Container
              _iconsOverlay(0.62, 0.8, ags, 'ag')
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
                displayText = selectedItem;
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
        Colors.white.withOpacity(0.5),
        score,
      ),
    );
  }


  Widget _iconsOverlay(double topMultiplicator, double leftMultiplicator, var data, String infoBox) {
    return Positioned(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      top: MediaQuery.of(context).size.height * topMultiplicator,
      left: MediaQuery.of(context).size.width * leftMultiplicator,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.edit,
                color: Colors.blue), // Button-Farbe ändern
            onPressed: () {
              _showSecondOverlay(data, infoBox);
            },
          ),
          IconButton(
            icon: Icon(Icons.check,
                color: Colors.green), // Button-Farbe ändern
            onPressed: () {
              //Pageroute hinzufügen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBox(
      String text, double width, double height, Color color, double score) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getColorFromScore(score),
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
      ),
    );
  }

  Color _getColorFromScore(double score) {
    if (score >= 0.9) {
      return Colors.green;
    } else if (score >= 0.75) {
      return Colors.orange;
    } else if (score < 0.75 && score >= 0.5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
