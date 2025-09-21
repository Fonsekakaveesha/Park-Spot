// ignore_for_file: file_names, unused_import, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ignore: unnecessary_import
import 'package:flutter/widgets.dart';

// ignore: unused_import
import 'dart:ui' as dart_ui;

import 'package:flutter/foundation.dart' show kIsWeb;

class QRCodeScreen extends StatelessWidget {
  final String data;
  const QRCodeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your QR Code')),
      body: Center(
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}

// Use qr_code_scanner only on mobile platforms (not web).

// ignore: undefined_prefixed_name