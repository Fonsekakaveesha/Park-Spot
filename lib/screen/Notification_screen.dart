// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref('notifications');
  late Stream<DatabaseEvent> _notificationsStream;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    // Listen to notifications for the current user
    _notificationsStream = _notificationsRef.child(_userId ?? '').onValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('No notifications yet.'));
          }

          final data = Map<String, dynamic>.from(
            (snapshot.data!.snapshot.value as Map)
          );

          final notifications = data.entries.map((e) {
            final value = Map<String, dynamic>.from(e.value);
            return {
              'title': value['title'] ?? 'No Title',
              'body': value['body'] ?? '',
              'timestamp': value['timestamp'] ?? '',
            };
          }).toList();

          notifications.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(notification['title']),
                subtitle: Text(notification['body']),
                trailing: Text(
                  notification['timestamp'].toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

