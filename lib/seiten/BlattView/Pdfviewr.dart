import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViwer extends StatefulWidget {
  const PdfViwer({Key? key}) : super(key: key);

  @override
  PdfViwerState createState() => PdfViwerState();
}

class PdfViwerState extends State<PdfViwer> {
  int? currentPage = 0;
  bool pdfReady = false;
  OverlayEntry? _overlayEntry;
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  String? path;
  Map<String, dynamic> _jsonData = {};
  bool dataLoaded = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    readJson().then((value) => setState(() {
          _showOverlay(context);
        }));
  }

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/Daten/ag_sample.json');
    var responseJson = await json.decode(response);
    var f =
        await getFileFromAsset("assets/Doc/${responseJson['doc_type']}.pdf");
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

  void _nextData() {
    setState(() {
      _currentIndex =
          ((_currentIndex + 1) % _jsonData['students'].length).toInt();
      _overlayEntry?.remove();
      _showOverlay(context);
    });
  }

  void _prevData() {
    setState(() {
      _currentIndex = ((_currentIndex - 1 + _jsonData['students'].length) %
              _jsonData['students'].length)
          .toInt();
      _overlayEntry?.remove();
      _showOverlay(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erfasste Schüler Blatt"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _prevData,
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _nextData,
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
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.15,
                top: MediaQuery.of(context).size.height * 0.46,
                left: MediaQuery.of(context).size.width * 0.05,
                child: GestureDetector(
                  onTap: () {
                    print("Overlay getippt");
                  },
                  child: _buildOverlayBox(
                    'test',
                    MediaQuery.of(context).size.width * 0.7,
                    MediaQuery.of(context).size.height * 0.15,
                    Colors.blue.withOpacity(0.5),
                    0.78,
                  ),
                ),
              ),
              // Position für Button-Container
              Positioned(
                width: MediaQuery.of(context).size.width *
                    0.1, // Breite des Button-Containers
                height: MediaQuery.of(context).size.height * 0.15,
                top: MediaQuery.of(context).size.height * 0.46,
                left: MediaQuery.of(context).size.width *
                    0.76, // Linke Position anpassen, um Buttons rechts zu platzieren
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue), // Button-Farbe ändern
                      onPressed: () {
                        _showOverlayList(context, 'Adresse'); // **Geändert**
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
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.40,
                left: MediaQuery.of(context).size.width * 0.05,
                child: GestureDetector(
                  onTap: () {
                    print("Overlay getippt");
                  },
                  child: _buildOverlayBox(
                    'test',
                    MediaQuery.of(context).size.width * 0.7,
                    MediaQuery.of(context).size.height * 0.108,
                    Colors.blue.withOpacity(0.5),
                    0.48,
                  ),
                ),
              ),
              // Position für Button-Container
              Positioned(
                width: MediaQuery.of(context).size.width *
                    0.1, // Breite des Button-Containers
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.40,
                left: MediaQuery.of(context).size.width *
                    0.76, // Linke Position anpassen, um Buttons rechts zu platzieren
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue), // Button-Farbe ändern
                      onPressed: () {
                        _showOverlayList(context, 'Adresse'); // **Geändert**
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
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.22,
                top: MediaQuery.of(context).size.height * 0.86,
                left: MediaQuery.of(context).size.width * 0.05,
                child: GestureDetector(
                  onTap: () {
                    print("Overlay getippt");
                  },
                  child: _buildOverlayBox(
                    'test',
                    MediaQuery.of(context).size.width * 0.7,
                    MediaQuery.of(context).size.height * 0.22,
                    Colors.blue.withOpacity(0.5),
                    0.56,
                  ),
                ),
              ),
              // Position für Button-Container
              Positioned(
                width: MediaQuery.of(context).size.width *
                    0.1, // Breite des Button-Containers
                height: MediaQuery.of(context).size.height * 0.22,
                top: MediaQuery.of(context).size.height * 0.86,
                left: MediaQuery.of(context).size.width *
                    0.76, // Linke Position anpassen, um Buttons rechts zu platzieren
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue), // Button-Farbe ändern
                      onPressed: () {
                        _showOverlayList(context, 'Adresse'); // **Geändert**
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
              ),
            ],
          ),
        );
      } else {
        var student = _jsonData['students'][_currentIndex];
        var ags = _jsonData['AGS'];
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.508,
                left: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    print("Overlay getippt");
                  },
                  child: _buildOverlayBox(
                    '${student['nachname']['value']}\n${student['vorname']['value']}\n${student['class']['value']}',
                    MediaQuery.of(context).size.width * 0.7,
                    MediaQuery.of(context).size.height * 0.108,
                    Colors.white.withOpacity(0.5),
                    student['similarityScorePerson'],
                  ),
                ),
              ),
              // Position für Button-Container
              Positioned(
                width: MediaQuery.of(context).size.width *
                    0.1, // Breite des Button-Containers
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.508,
                left: MediaQuery.of(context).size.width *
                    0.8, // Linke Position anpassen, um Buttons rechts zu platzieren
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue), // Button-Farbe ändern
                      onPressed: () {
                        _showOverlayList(context, 'students'); // **Geändert**
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
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.62,
                left: MediaQuery.of(context).size.width * 0.1,
                child: GestureDetector(
                  onTap: () {
                    print("Overlay getippt");
                  },
                  child: _buildOverlayBox(
                    '${ags[0]['Ag_name']['value']}\n${ags[1]['Ag_name']['value']}\nChor',
                    MediaQuery.of(context).size.width * 0.7,
                    MediaQuery.of(context).size.height * 0.108,
                    Colors.white.withOpacity(0.5),
                    ags[0]['Ag_name']['score'],
                  ),
                ),
              ),
              // Position für Button-Container
              Positioned(
                width: MediaQuery.of(context).size.width *
                    0.1, // Breite des Button-Containers
                height: MediaQuery.of(context).size.height * 0.108,
                top: MediaQuery.of(context).size.height * 0.62,
                left: MediaQuery.of(context).size.width *
                    0.8, // Linke Position anpassen, um Buttons rechts zu platzieren
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue), // Button-Farbe ändern
                      onPressed: () {
                        _showOverlayList(context, 'AGS'); // **Geändert**
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

  void _showOverlayList(BuildContext context, String dataType) {
    // **Geändert**
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        List<Map<String, dynamic>> dataList = dataType == 'students'
            ? List<Map<String, dynamic>>.from(_jsonData['students'])
            : List<Map<String, dynamic>>.from(_jsonData['AGS']);
        return Positioned(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.3,
          top: MediaQuery.of(context).size.height * 0.1,
          left: MediaQuery.of(context).size.width * 0.15,
          child: Material(
            color: Colors.transparent,
            child: _buildOverlayList(
                dataList,
                MediaQuery.of(context).size.width * 0.7,
                MediaQuery.of(context).size.height * 0.3,
                Colors.blueGrey),
          ),
        );
      },
    );

    Overlay.of(context)!.insert(overlayEntry);

    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
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

  Widget _buildOverlayList(List<Map<String, dynamic>> dataList, double width,
      double height, Color color) {
    // **Geändert**
    if (dataList.isNotEmpty) {
      return Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                var data = dataList[index];
                if (data.containsKey('vorname') &&
                    data.containsKey('nachname') &&
                    data.containsKey('class')) {
                  return FittedBox(
                    child: Text(
                      '${data['vorname']['value']} ${data['nachname']['value']} ${data['class']['value']}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return FittedBox(
                    child: Text(
                      data['Ag_name']['value'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          width: width,
          height: height,
          child: const Center(
            child: FittedBox(
              child: Text(
                'Keine Daten vorhanden',
                style: TextStyle(
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
