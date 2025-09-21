// ignore_for_file: file_names, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            // Filter only bookings made by current user (optional)
            .where('user', isEqualTo: user?.uid)
            .orderBy('bookingTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading bookings'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          return SafeArea(
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final data = bookings[index].data() as Map<String, dynamic>;
                final id = bookings[index].id;

                final bookingTime = data['bookingTime'] is Timestamp
                    ? (data['bookingTime'] as Timestamp).toDate()
                    : null;

                final cancelledAt = data['cancelledAt'] is Timestamp
                    ? (data['cancelledAt'] as Timestamp).toDate()
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    title: Text(
                      "Slot: ${data['slot'] ?? 'N/A'} | Status: ${data['status'] ?? 'unknown'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vehicle: ${data['vehicleNumber'] ?? 'N/A'}"),
                        if (data['user'] != null) Text("User: ${data['user']}"),
                        if (bookingTime != null)
                          Text(
                            "Booked at: $bookingTime",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (cancelledAt != null)
                          Text(
                            "Cancelled at: $cancelledAt",
                            style: const TextStyle(fontSize: 12, color: Colors.red),
                          ),
                      ],
                    ),
                    trailing: data['status'] == 'active'
                        ? TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(id)
                                  .update({
                                'status': 'cancelled',
                                'cancelledAt': FieldValue.serverTimestamp(),
                              });

                              // Optional: Free the slot as well
                              final slotId = data['slot'];
                              final type = data['type']; // 'car', 'van', 'moto', 'wheels'

                              if (slotId != null && type != null) {
                                await FirebaseFirestore.instance
                                    .collection('${type}_slots') // dynamic collection
                                    .doc(slotId)
                                    .update({
                                  'isBooked': false,
                                  'bookedBy': null,
                                });
                              }
                            },
                            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
