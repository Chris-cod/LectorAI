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
  late String fileType = "";
  String? path;

  @override
  void initState() {
    super.initState();
    initDoc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(context);
    });
  }

  void initDoc() async {
    fileType = await readJson();
    getFileFromAsset("assets/Doc/$fileType.pdf").then((f) {
      setState(() {
        path = f.path;
        pdfReady = true;
      });
    });
  }

  Future<File> getFileFromAsset(String asset) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$fileType.pdf");
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

  Future<String> readJson() async {
    final String response =
        await rootBundle.loadString('assets/Daten/document.json');
    final data = await json.decode(response);
    return data['doc-type'];
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
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: 492.0,
            left: 30.0,
            child: GestureDetector(
              onTap: () {
                // Handle tap for Schüler/in to Klasse
                print("Schüler/in bis Klasse tapped");
              },
              child: _buildOverlayBox(
                "Schüler/in\nName",
                320,
                80,
                Colors.blue.withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            top: 580.0,
            left: 30.0,
            child: GestureDetector(
              onTap: () {
                // Handle tap for AG to AG Wahl 3
                print("AG bis AG Wahl 3 tapped");
              },
              child: _buildOverlayBox(
                "AG\nAG Wahl 1\nAG W..",
                320,
                80,
                Colors.green.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayBox(
      String text, double width, double height, Color color) {
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
