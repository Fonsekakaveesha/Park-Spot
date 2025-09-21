// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, file_names, depend_on_referenced_packages, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:final_pro/screen/HomePage.dart';
import 'package:final_pro/screen/CancleBooking_screen.dart';
import 'package:final_pro/screen/PaymentScreen.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:final_pro/services/database_service.dart';

class BookSpotPage extends StatefulWidget {
  final String slotId;

  // ignore: use_super_parameters
  const BookSpotPage({Key? key, required this.slotId}) : super(key: key);

  @override
  _BookSpotPageState createState() => _BookSpotPageState();
}

class _BookSpotPageState extends State<BookSpotPage> {
  final _nameController = TextEditingController();
  final _vehicleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _arrivingTime;
  TimeOfDay? _exitTime;
  double _totalAmount = 0.0;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isArriving) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isArriving) {
          _arrivingTime = picked;
        } else {
          _exitTime = picked;
        }

        if (_arrivingTime != null && _exitTime != null) {
          _calculateDurationAndAmount();
        }
      });
    }
  }

  void _calculateDurationAndAmount() {
    final arrive = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _arrivingTime!.hour,
      _arrivingTime!.minute,
    );
    final exit = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _exitTime!.hour,
      _exitTime!.minute,
    );

    final duration = exit.difference(arrive).inMinutes;
    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exit time must be after arrival time")),
      );
      return;
    }

    double hourlyRate = 100.0;
    double hours = duration / 60.0;
    double amount = (hours * hourlyRate);
    setState(() {
      _totalAmount = amount.ceilToDouble();
    });
  }

  void _bookSpot() async {
    final name = _nameController.text;
    final vehicle = _vehicleController.text;
    final user = _auth.currentUser;

    if (name.isEmpty ||
        vehicle.isEmpty ||
        _selectedDate == null ||
        _arrivingTime == null ||
        _exitTime == null ||
        user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final bookingId = const Uuid().v4();
    final arriveDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _arrivingTime!.hour,
      _arrivingTime!.minute,
    );

    final exitDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _exitTime!.hour,
      _exitTime!.minute,
    );

    if (exitDateTime.isBefore(arriveDateTime) ||
        exitDateTime.isAtSameMomentAs(arriveDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exit time must be after arrival time")),
      );
      return;
    }

    final dbService = DatabaseService();

    // --- Check for overlapping bookings ---
    final available = await dbService.isSlotAvailable(
      widget.slotId,
      arriveDateTime,
      exitDateTime,
    );
    if (!available) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot is already booked for the selected time.'),
        ),
      );
      return;
    }

    final bookingData = {
      'bookingId': bookingId,
      'userId': user.uid,
      'slotId': widget.slotId,
      'name': name,
      'vehicleNumber': vehicle,
      'date': _selectedDate!.toIso8601String(),
      // ignore: use_build_context_synchronously
      'arrivingTime': _arrivingTime!.format(context),
      // ignore: use_build_context_synchronously
      'exitTime': _exitTime!.format(context),
      'startDateTime': arriveDateTime,
      'endDateTime': exitDateTime,
      'durationInMinutes': exitDateTime.difference(arriveDateTime).inMinutes,
      'amount': _totalAmount,
      'paymentStatus': 'Pending',
      'status': 'booked',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('bookings').doc(bookingId).set(bookingData);

    _monitorBookingEndTime(bookingId, exitDateTime);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingConfirmationPage(
              slotId: widget.slotId,
              name: name,
              vehicleNumber: vehicle,
              date: _selectedDate!,
              arrivingTime: _arrivingTime!,
              exitTime: _exitTime!,
              amount: _totalAmount,
              bookingId: bookingId,
            ),
      ),
    );
  }

  // ignore: unused_element
  void _monitorBookingEndTime(String bookingId, DateTime exitTime) {
    Timer(exitTime.difference(DateTime.now()), () async {
      final docRef = _firestore.collection('bookings').doc(bookingId);
      final doc = await docRef.get();

      if (doc.exists) {
        final status = doc['paymentStatus'];
        if (status == 'Pending') {
          await docRef.update({
            'paymentStatus': 'Overdue',
            'overdueNoticeSent': true,
            'extraCharge': 150.0,
          });
          // ignore: avoid_print
          print("🚨 User overdue - Notification should be triggered");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F1F6),
      appBar: AppBar(
        title: const Text('Book a Parking Spot'),
        backgroundColor: const Color(0xFF7AB7DA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Lottie.network(
              'https://lottie.host/e285e441-93b5-47e7-9ea2-ab202cb12c04/MDfWDDoBVZ.json',
              width: 400,
              height: 300,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter Your Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                labelText: 'Enter Your Vehicle Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate != null
                    ? 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                    : 'Select Date',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(
                      'Arriving: ${_arrivingTime?.format(context) ?? 'Select'}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(
                      'Exit: ${_exitTime?.format(context) ?? 'Select'}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_totalAmount > 0)
              Text(
                'Estimated Cost: Rs. $_totalAmount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _bookSpot,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 70,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingConfirmationPage extends StatelessWidget {
  final String slotId;
  final String name;
  final String vehicleNumber;
  final DateTime date;
  final TimeOfDay arrivingTime;
  final TimeOfDay exitTime;
  final double amount;
  final String bookingId;

  const BookingConfirmationPage({
    required this.slotId,
    required this.name,
    required this.vehicleNumber,
    required this.date,
    required this.arrivingTime,
    required this.exitTime,
    required this.amount,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.network(
                    'https://lottie.host/fd76a9b4-fa20-4377-a559-4c1969e26b22/LKsTwFp6NW.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Slot Booked Successfully!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Slot Number: $slotId',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text('Name: $name', style: const TextStyle(fontSize: 18)),
                  Text(
                    'Vehicle: $vehicleNumber',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Date: ${date.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Arriving: ${arrivingTime.format(context)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Exit: ${exitTime.format(context)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Payment: Pending',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ConfirmBookingPage(
                                      slotId: slotId,
                                      amount: amount,
                                      arrivingTime: arrivingTime,
                                      exitTime: exitTime,
                                    ),
                              ),
                              (route) => false,
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DBCFB),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CancelBookingScreen(
                                      bookingId: bookingId,
                                    ),
                              ),
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Cancel Booking',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Move ConfirmPage class definition outside of BookingConfirmationPage
class ConfirmBookingPage extends StatelessWidget {
  final String slotId;
  final double amount;
  final TimeOfDay arrivingTime;
  final TimeOfDay exitTime;

  // ignore: use_super_parameters
  const ConfirmBookingPage({
    Key? key,
    required this.slotId,
    required this.amount,
    required this.arrivingTime,
    required this.exitTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/f6cc9842-54e3-40be-8dd0-ff772d5f4f8c/0IUjDIJa6O.json',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentScreen(
                            slotId: slotId,
                            amount: amount,
                            startTime: DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              arrivingTime.hour,
                              arrivingTime.minute,
                            ),
                            endTime: DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                              exitTime.hour,
                              exitTime.minute,
                            ),
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Payment', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmPage extends StatelessWidget {
  final String slotId;
  final double amount;
  final DateTime arrivingTime;
  final DateTime exitTime;

  // ignore: use_super_parameters
  const ConfirmPage({
    Key? key,
    required this.slotId,
    required this.amount,
    required this.arrivingTime,
    required this.exitTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://lottie.host/f6cc9842-54e3-40be-8dd0-ff772d5f4f8c/0IUjDIJa6O.json',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PaymentScreen(
                            slotId: slotId,
                            amount: amount,
                            startTime: arrivingTime,
                            endTime: exitTime,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Payment', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookSpotScreen extends StatefulWidget {
  final String slotType; // e.g., 'car', 'van', 'moto', 'wheels'
  final String slotId;

  const BookSpotScreen({
    super.key,
    required this.slotType,
    required this.slotId,
  });

  @override
  State<BookSpotScreen> createState() => _BookSpotScreenState();
}

class _BookSpotScreenState extends State<BookSpotScreen> {
  bool isBooking = false;
  String? bookingStatus;

  // Add these controllers to get time from user
  DateTime? _selectedDate;
  TimeOfDay? _arrivingTime;
  TimeOfDay? _exitTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isArriving) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isArriving) {
          _arrivingTime = picked;
        } else {
          _exitTime = picked;
        }
      });
    }
  }

  Future<void> bookSlot() async {
    setState(() {
      isBooking = true;
      bookingStatus = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isBooking = false;
        bookingStatus = 'User not logged in.';
      });
      return;
    }

    if (_selectedDate == null || _arrivingTime == null || _exitTime == null) {
      setState(() {
        isBooking = false;
        bookingStatus = 'Please select date, arrival and exit time.';
      });
      return;
    }

    final startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _arrivingTime!.hour,
      _arrivingTime!.minute,
    );
    final endTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _exitTime!.hour,
      _exitTime!.minute,
    );

    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      setState(() {
        isBooking = false;
        bookingStatus = 'Exit time must be after arrival time.';
      });
      return;
    }

    try {
      final dbService = DatabaseService();
      switch (widget.slotType) {
        case 'car':
          await dbService.bookCarSlot(
            widget.slotId,
            user.uid,
            startTime,
            endTime,
          );
          break;
        case 'van':
          await dbService.bookVanSlot(
            widget.slotId,
            user.uid,
            startTime,
            endTime,
          );
          break;
        case 'moto':
          await dbService.bookMotoSlot(
            widget.slotId,
            user.uid,
            startTime,
            endTime,
          );
          break;
        case 'wheels':
          await dbService.bookWheelsSlot(
            widget.slotId,
            user.uid,
            startTime,
            endTime,
          );
          break;
        default:
          throw Exception('Unknown slot type');
      }

      // Optionally, add a booking record for the user
      await dbService.addSlotBooking(user.uid, {
        'slotId': widget.slotId,
        'slotType': widget.slotType,
        'userId': user.uid,
        'bookedAt': DateTime.now(),
        'startTime': startTime,
        'endTime': endTime,
        'status': 'booked',
      });

      setState(() {
        isBooking = false;
        bookingStatus = 'Booking successful!';
      });
    } catch (e) {
      setState(() {
        isBooking = false;
        bookingStatus = 'Booking failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Parking Spot')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Slot Type: ${widget.slotType}'),
              Text('Slot ID: ${widget.slotId}'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate != null
                      ? 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                      : 'Select Date',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(
                        'Arriving: ${_arrivingTime?.format(context) ?? 'Select'}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(
                        'Exit: ${_exitTime?.format(context) ?? 'Select'}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isBooking ? null : bookSlot,
                child:
                    isBooking
                        ? const CircularProgressIndicator()
                        : const Text('Book Spot'),
              ),
              if (bookingStatus != null) ...[
                const SizedBox(height: 24),
                Text(
                  bookingStatus!,
                  style: TextStyle(
                    color:
                        bookingStatus == 'Booking successful!'
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
