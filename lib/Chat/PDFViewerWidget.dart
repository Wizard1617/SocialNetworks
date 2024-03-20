import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PDFViewerWidget extends StatefulWidget {
  final String url;

  PDFViewerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _PDFViewerWidgetState createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  late Future<File> _loadedFile;

  Future<File> loadPdf() async {
    final response = await http.get(Uri.parse(widget.url));
    final bytes = response.bodyBytes;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pdf.pdf');

    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  void initState() {
    super.initState();
    _loadedFile = loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _loadedFile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return PDFView(
              filePath: snapshot.data!.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Ошибка загрузки PDF: ${snapshot.error}'),
            );
          }
        }
        // Пока PDF загружается, показываем индикатор загрузки
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
