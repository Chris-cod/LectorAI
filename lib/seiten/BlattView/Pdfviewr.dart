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
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  String? path;
  Map<String, dynamic> _jsonData = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initDoc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(context);
    });
  }

  void initDoc() async {
    _jsonData = await readJson();
    getFileFromAsset("assets/Doc/${_jsonData['doc_type']}.pdf").then((f) {
      setState(() {
        path = f.path;
        pdfReady = true;
      });
    });
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
      throw Exception("Error opening asset file" + e.toString());
    }
    return completer.future;
  }

  Future<Map<String, dynamic>> readJson() async {
    final String response = await rootBundle.loadString('assets/Daten/adresse_sample.json');
    var data = await json.decode(response);
    return data;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = _createOverlayEntry(context);
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _nextData() {
    setState(() {
      _currentIndex = ((_currentIndex + 1) % _jsonData['students'].length).toInt();
    });
  }

  void _prevData() {
    setState(() {
      _currentIndex = ((_currentIndex - 1 + _jsonData['students'].length) % _jsonData['students'].length).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erfasste Schueler Blatt"),
      ),
      body:
          path != null ? showPDF() : Center(child: CircularProgressIndicator()),
    );
  }

  Widget showPDF() {
    return PDFView(
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
      onPageError: (page, e) {},
    );
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    try {
      var student = _jsonData['students'][_currentIndex];
      var parent = student['parents'].isNotEmpty ? student['parents'][0] : null;
      var address = _jsonData['addresses'].firstWhere((addr) => addr['id'] == student['id'], orElse: () => null);
      var ags = _jsonData['AGs'][_currentIndex];
      if(_jsonData['doc_type'] == "Adresse") {
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              _buildOverlay(MediaQuery.of(context).size.width * 0.5, MediaQuery.of(context).size.height * 0.22, MediaQuery.of(context).size.height * 0.46,
                          MediaQuery.of(context).size.width * 0.15, '${parent['nachname']['value']}\n${parent['vorname']['value']}\n${parent['email']['value']}\n${parent['telefon']['value']}'),
              _buildOverlay(MediaQuery.of(context).size.width * 0.7, MediaQuery.of(context).size.height * 0.22, MediaQuery.of(context).size.height * 0.66,
                          MediaQuery.of(context).size.width * 0.46, '${student['nachname']['value']}\n${student['vorname']['value']}\n${student['class']['value']}'),
              _buildOverlay(MediaQuery.of(context).size.width * 0.9, MediaQuery.of(context).size.height * 0.22, MediaQuery.of(context).size.height * 0.86,
                          MediaQuery.of(context).size.width * 0.46, '${address['street_name']['value']}\n${address['location']['postal_code']}\n${address['location']['location_name']}')
            ],
          ),
        );
      } else {
        return OverlayEntry(
          builder: (context) => Stack(
            children: [
              _buildOverlay(MediaQuery.of(context).size.width * 0.7, MediaQuery.of(context).size.width * 0.7, MediaQuery.of(context).size.height * 0.46,
                          MediaQuery.of(context).size.height * 0.46, '${student['vorname']['value']}\n${student['nachname']['value']}\n${student['class']['value']}'),
              _buildOverlay(MediaQuery.of(context).size.width * 0.7, MediaQuery.of(context).size.width * 0.7, MediaQuery.of(context).size.height * 0.46,
                          MediaQuery.of(context).size.height * 0.46, '${ags['Ag_name']['value']}'),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
      return OverlayEntry(builder: (context) => Container());
    }
    
  }

  Widget _buildOverlay(double width, double height, double top, double left, String text) {
    return Positioned(
      width: width,
      height: height,
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          // Handle tap for Schüler/in to Klasse
          print("Schüler/in bis Klasse tapped");
        },
        child: _buildOverlayBox(
          text,
          220,
          80,
          Colors.blue.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOverlayBox(
      String text, double width, double height, Color color, ) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.red,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
