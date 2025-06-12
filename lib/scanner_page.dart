import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final url = 'b6d4-2603-8001-58f0-7770-7462-3dc3-ab69-e46f.ngrok-free.app';
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.pdf417],
  );

  bool _isLoading = false;
  String? _errorMessage;

  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.format == BarcodeFormat.pdf417 && barcode.rawValue != null) {
        setState(() {
          _scanned = true;
        });

        final patronData = parsePdf417(barcode.rawValue!);
        final _url = Uri.parse('https://$url/check_id');

        print("Patron data parsed: ${patronData}");

        try {
          final jsonBody = jsonEncode(patronData);
          print("Sending JSON body: $jsonBody");

          final response = await http.post(
            _url,
            headers: {'Content-Type': 'application/json'},
            body: jsonBody,
          );

          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            print("Success data: $data");
          } else {
            final error = jsonDecode(response.body)['error'] ?? 'ID check failed';
            setState(() {
              _errorMessage = error;
              _isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Network error: $e';
            _isLoading = false;
          });
        }


        //this is the place to get the id information
        _controller.stop();
        break;
      }
    }
  }

  Map<String, String> parsePdf417(String raw) {
    final Map<String, String> data = {};
    final lines = raw.split(RegExp(r'\n|\r'));
    lines.forEach(print);
    for (var line in lines) {
      if (line.startsWith('DCS')) data['last_name'] = line.substring(3).trim();
      if (line.startsWith('DAC')) data['first_name'] = line.substring(3).trim();
      if (line.startsWith('DAD')) data['middle_name'] = line.substring(3).trim();
      if (line.startsWith('DBB')) data['dob'] = line.substring(3).trim(); // DDMMYYYY

      if (line.startsWith('DCK')){
        var licenseString = line.substring(8).trim();
        var finalString = licenseString.substring(0, licenseString.length - 4);
        data['license_number'] = finalString;
      }
    }
    return data;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan License')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWidth = constraints.maxWidth / 1.1;
          final scanHeight = constraints.maxHeight / 5;
          final left = (constraints.maxWidth - scanWidth) / 2;
          final top = (constraints.maxHeight - scanHeight) / 15;

          final scanRect = Rect.fromLTWH(left, top, scanWidth, scanHeight);

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: scanWidth,
                height: scanHeight,
                child: ClipRect(
                  child: MobileScanner(
                    controller: _controller,
                    scanWindow: Rect.fromLTWH(0, 0, scanWidth, scanHeight),
                    fit: BoxFit.cover,
                    onDetect: _onDetect,
                  ),
                ),
              ),
              // Visual guide for scan area (optional)
              Positioned(
                left: left,
                top: top,
                width: scanWidth,
                height: scanHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                ),
              ),
              // Optional scan complete overlay
              if (_scanned)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    color: Colors.black.withOpacity(0.6),
                    child: Text(
                      'Scan complete',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.restart_alt),
        onPressed: () {
          setState(() {
            _scanned = false;
          });
          _controller.start();
        },
      ),
    );
  }

}
