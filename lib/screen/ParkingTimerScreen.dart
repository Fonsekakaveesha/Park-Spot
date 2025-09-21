// ignore_for_file: file_names, library_private_types_in_public_api, use_key_in_widget_constructors, sort_child_properties_last, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'PaymentScreen.dart'; // Import the PaymentScreen

void main() {
  runApp(ParkingTimerApp());
}

// ignore: use_key_in_widget_constructors
class ParkingTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ParkingTimerScreen(),
    );
  }
}

class ParkingTimerScreen extends StatefulWidget {
  @override
  _ParkingTimerScreenState createState() => _ParkingTimerScreenState();
}

class _ParkingTimerScreenState extends State<ParkingTimerScreen> {
  Duration duration = const Duration(hours: 24);
  Timer? timer;

  void startTimer() {
    if (timer != null) {
      timer!.cancel();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (duration.inSeconds > 0) {
          duration = Duration(seconds: duration.inSeconds - 1);
        } else {
          timer.cancel();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Time is up!')));
        }
      });
    });
  }

  void extendTime() {
    setState(() {
      duration += const Duration(minutes: 30); // Extend time by 30 minutes
    });
  }

  void makePayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PaymentScreen(
              slotId: 'C2',
              amount: 300.00,
              startTime: DateTime(2024, 1, 16, 8, 30),
              endTime: DateTime(2024, 1, 16, 10, 30),
            ), // Navigate to PaymentScreen
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = duration.toString().split('.').first.padLeft(8, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Timer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6F1F6), // Light top
              Color(0xFF7AB7DA), // Blue middle
              Color(0xFF84CDEE), // Dark blue bottom
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remaining Parking Time',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: startTimer,
                  child: const Text('Start Timer'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: extendTime,
                  child: const Text('Extend Parking Time'),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Booking Details:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Name: Anton Fonseka'),
                        Text('Vehicle Number Plate: GR 456 - EFGH'),
                        Text('Slot: C2'),
                        Text('Arriving Time: 8:30 AM'),
                        Text('Exit Time: 10:30 AM'),
                        Text('Date: January 16'),
                        Text('Total Payment: Rs.300.00'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // ✅ Lottie animation updated to clean timer animation
                Lottie.network(
                  'https://lottie.host/f037d31b-cd43-4be5-bf25-22c6bd52dc57/w1u9bCrbnV.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: makePayment,
                  child: const Text('Make Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
