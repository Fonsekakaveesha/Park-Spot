// ignore_for_file: file_names, depend_on_referenced_packages, prefer_typing_uninitialized_variables, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async' show StreamController;

import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({super.key});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        controller!.pauseCamera();
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        controller!.resumeCamera();
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (scanned) return;
      scanned = true;
      String scannedCode = scanData.code ?? "";
      if (scannedCode.isNotEmpty) {
        await _handleQRScan(scannedCode);
      }
    });
  }

  Future<void> _handleQRScan(String scannedCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check for matching parking entry gate
      final gateRef =
          await FirebaseFirestore.instance
              .collection('gates')
              .doc(scannedCode)
              .get();

      if (!gateRef.exists) {
        _showMessage("Invalid QR code or gate not registered.");
        return;
      }

      // ignore: use_build_context_synchronously
      Navigator.of(
        // ignore: use_build_context_synchronously
        context,
      ).pushReplacementNamed('/qrScanner', arguments: scannedCode);
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String msg) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("QR Scan Info"),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Scanner")),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          const Expanded(
            flex: 1,
            child: Center(child: Text('Scan your QR code to continue')),
          ),
        ],
      ),
    );
  }

  // ignore: strict_top_level_inference
  QRView({
    required GlobalKey<State<StatefulWidget>> key,
    required void Function(QRViewController controller) onQRViewCreated,
  }) {}
}

class QRViewController {
  // Dummy stream for scannedDataStream to avoid compile error
  Stream<ScanData> get scannedDataStream => _scannedDataController.stream;
  final _scannedDataController = StreamController<ScanData>.broadcast();

  void pauseCamera() {}

  void resumeCamera() {}

  void dispose() {
    _scannedDataController.close();
  }

  // Add any other necessary methods or properties here
}

// Dummy ScanData class to avoid compile error
class ScanData {
  final String? code;
  ScanData(this.code);
}
