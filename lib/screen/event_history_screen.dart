import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: use_key_in_widget_constructors
class EventHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Event History")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('cctv_events')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              var data = docs[i];
              return ListTile(
                leading: Image.network(data['url']),
                title: Text(data['event']),
                subtitle: Text(data['timestamp'].toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
