import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late CameraController _cameraController;
  late BarcodeScanner _barcodeScanner;
  late InputImageFormat _inputImageFormat;
  late ImageFormatGroup _cameraImageFormatGroup;

  bool _isDetecting = false;
  bool _isCameraInitialized = false;


  


  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitialize();
    
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan License")),
      body: _isCameraInitialized
          ? CameraPreview(_cameraController)
          : Center(child: Text("Waiting for permissions...")),
    );
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
      _showPermissionsDeniedDialog();
      return;
    }

    final newCameraStatus = await Permission.camera.request();
    final newMicStatus = await Permission.microphone.request();

    if (!newCameraStatus.isGranted || !newMicStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera or Microphone permission denied")),
      );
      return;
    }

    await _initializeCameraAndScanner();
  }

  Future<void> _initializeCameraAndScanner() async {

    _inputImageFormat = Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.yuv420;
    _cameraImageFormatGroup = Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420;

    print(_inputImageFormat);
    print(_cameraImageFormatGroup);
    print(_isCameraInitialized);

    if(_isCameraInitialized){
      try{
        await _cameraController.stopImageStream();
      }catch (_){}

      try{
        await _cameraController.dispose();
      }catch (_){
        _isCameraInitialized = false;
      }
    }

    final cameras = await availableCameras();

    cameras.forEach(print);

    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    print('BackCamera: $backCamera');

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      imageFormatGroup: _cameraImageFormatGroup,
    );
    await _cameraController.initialize();

    print("Camera controller: $_cameraController");

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.pdf417]);
    setState(() {
      _isCameraInitialized = true;
    });

    print('Barcode scanner: $_barcodeScanner');

    Future.delayed(Duration(milliseconds: 1000), (){
      try{
        _cameraController.startImageStream((CameraImage image){
          _processCameraImage(image);
        }); 
      }catch (e){
        debugPrint("Failed to start image stream: $e");
      }
    });
  }

  Uint8List _concatenatePlanes(List<Plane> planes){
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes){
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _rotationIntToEnum(_cameraController.description.sensorOrientation),
          format: _inputImageFormat,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final barcodes = await _barcodeScanner.processImage(inputImage);

      for (final barcode in barcodes) {
        if (barcode.format == BarcodeFormat.pdf417) {
          debugPrint("PDF417 Detected: ${barcode.rawValue}");
        }
      }
    } catch (e) {
      debugPrint("Error trying to process camera image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  InputImageRotation _rotationIntToEnum(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        throw Exception("Invalid rotation value");
    }
  }


  void _showPermissionsDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permissions Required"),
        content: Text(
            "Camera and microphone access are permanently denied. Please enable them in Settings to use the scanner."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
}

}
