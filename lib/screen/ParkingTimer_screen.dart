// ignore_for_file: library_private_types_in_public_api, use_super_parameters, file_names, camel_case_types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_pro/screen/TransactionSuccessScreen.dart';

class ParkingTimer_Screen extends StatefulWidget {
  const ParkingTimer_Screen({Key? key}) : super(key: key);

  @override
  _ParkingTimer_ScreenState createState() => _ParkingTimer_ScreenState();
}

class _ParkingTimer_ScreenState extends State<ParkingTimer_Screen> {
  Duration parkingDuration = const Duration(minutes: 35, seconds: 21);
  Timer? timer;
  bool isRunning = true;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (parkingDuration.inSeconds == 0) {
        t.cancel();
        setState(() => isRunning = false);
        _goToTransactionSuccess();
      } else {
        setState(() {
          parkingDuration = parkingDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
    _goToTransactionSuccess();
  }

  void _goToTransactionSuccess() {
    // Prevent multiple navigations
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TransactionSuccessScreen()),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDurationSeconds = 3600; // 1 hour for example
    int elapsedSeconds = totalDurationSeconds - parkingDuration.inSeconds;

    double progress = elapsedSeconds / totalDurationSeconds;
    if (progress > 1) progress = 1;

    final minutes = parkingDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = parkingDuration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Tabs Bar for Zones
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _zoneTab('ZONE 1', 'FULL', false),
                  _zoneTab('ZONE 2', 'AVAILABLE', true),
                  _zoneTab('ZONE 2', 'FULL', false),
                  _zoneTab('ZONE 2', '', false),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Car icon - use Flutter icon for simplicity
                        Icon(Icons.directions_car_filled, size: 60, color: Colors.black54),

                        const SizedBox(height: 12),

                        Text(
                          '$minutes : $seconds s',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        const SizedBox(height: 8),
                        const Text('PARKING ZONE 2, PILLER NO. 23', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: isRunning ? stopTimer : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 4,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.deepPurpleAccent,
                    shadowColor: Colors.deepPurpleAccent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text('STOP'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoneTab(String zoneTitle, String status, bool isActive) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? Colors.deepPurpleAccent : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
          bottom: Radius.circular(0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            zoneTitle,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: isActive
                  ? (status == 'AVAILABLE' ? Colors.white : Colors.grey.shade300)
                  : (status == 'AVAILABLE' ? Colors.blueAccent : Colors.grey),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}