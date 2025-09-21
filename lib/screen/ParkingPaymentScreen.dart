import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ParkingPaymentScreen extends StatefulWidget {
  final String slotId;
  final String userId;
  final double ratePerHour;

  const ParkingPaymentScreen({
    super.key,
    required this.slotId,
    required this.userId,
    this.ratePerHour = 100.0,
  });

  @override
  State<ParkingPaymentScreen> createState() => _ParkingPaymentScreenState();
}

class _ParkingPaymentScreenState extends State<ParkingPaymentScreen> {
  DateTime? startTime;
  DateTime? endTime;
  double totalAmount = 0.0;

  void calculateAmount() {
    if (startTime != null && endTime != null) {
      final duration = endTime!.difference(startTime!).inMinutes;
      final hours = (duration / 60).ceil(); // Round up to the next hour
      setState(() {
        totalAmount = hours * widget.ratePerHour;
      });
    }
  }

  Future<void> makePayment() async {
    if (startTime == null || endTime == null) return;

    final docRef = FirebaseFirestore.instance.collection('payments').doc();

    await docRef.set({
      'userId': widget.userId,
      'slotId': widget.slotId,
      'startTime': startTime,
      'endTime': endTime,
      'amount': totalAmount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(const SnackBar(content: Text('Payment Successful')));

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> selectTime(bool isStart) async {
    final now = DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (picked != null) {
      final fullDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        if (isStart) {
          startTime = fullDateTime;
        } else {
          endTime = fullDateTime;
        }
      });

      calculateAmount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Parking Payment'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Start Time"),
              subtitle: Text(
                startTime != null
                    ? dateFormat.format(startTime!)
                    : "Select start time",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => selectTime(true),
              ),
            ),
            ListTile(
              title: const Text("End Time"),
              subtitle: Text(
                endTime != null
                    ? dateFormat.format(endTime!)
                    : "Select end time",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () => selectTime(false),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Amount: LKR ${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed:
                  (startTime != null && endTime != null) ? makePayment : null,
              icon: const Icon(Icons.payment),
              label: const Text("Pay Now"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
