import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> uploadEvent(Uint8List fileBytes, String fileName) async {
    final ref = FirebaseStorage.instance.ref().child('events/$fileName');
    await ref.putData(fileBytes);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('cctv_events').add({
      'url': url,
      'timestamp': Timestamp.now(),
      'event': 'Motion Detected',
    });
  }
}
