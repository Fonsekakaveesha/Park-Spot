// ignore_for_file: file_names, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ParkingTimerScreen extends StatefulWidget {
  final String bookingId;
  const ParkingTimerScreen({super.key, required this.bookingId});

  @override
  State<ParkingTimerScreen> createState() => _ParkingTimerScreenState();
}

class _ParkingTimerScreenState extends State<ParkingTimerScreen> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _loadStartTime();
  }

  Future<void> _loadStartTime() async {
    final booking = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get();
    final Timestamp ts = booking['startTime'];
    _startTime = ts.toDate();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> _endParkingSession() async {
    _timer?.cancel();
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!);
    final cost = _calculateCost(duration);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .set({
        'endTime': Timestamp.fromDate(endTime),
        'duration': duration.inMinutes,
        'cost': cost,
        'status': 'completed',
      }, SetOptions(merge: true));

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Session Ended"),
          content: Text("Total cost: LKR $cost. Duration: ${duration.inMinutes} minutes."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to update booking: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  double _calculateCost(Duration duration) {
    double ratePerHour = 100.0; // LKR
    return (duration.inMinutes / 60) * ratePerHour;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    // ignore: unused_local_variable
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text("Parking Timer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Duration: $_elapsed",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _endParkingSession,
              child: const Text("End Session & Calculate Cost"),
            )
          ],
        ),
      ),
    );
  }
}
