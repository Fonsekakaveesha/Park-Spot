import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'package:firebase_database/ui/firebase_animated_list.dart'; // Ensure all Firebase types are available

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Write data to the specified path in Firebase Realtime Database
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _dbRef.child(path).set(data);
  }

  Future<DataSnapshot> readData(String path) async {
    return await _dbRef.child(path).get();
  }
  
    }
    
    // Removed the conflicting FirebaseDatabase class