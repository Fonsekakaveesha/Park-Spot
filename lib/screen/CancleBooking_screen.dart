// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:final_pro/screen/HomePage.dart';
import 'package:final_pro/services/database_service.dart';

class CancelBookingScreen extends StatefulWidget {
  final String bookingId;

  // ignore: use_super_parameters
  const CancelBookingScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  _CancelBookingScreenState createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  String? _selectedReason = 'Schedule Change';
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isLoading = false;

  final _reasons = [
    'Schedule Change',
    'Found Alternation Parking',
    'Change of Plans',
    'Booking Mistake',
    'Other',
  ];

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _cancelBooking() async {
    if (_selectedReason == null) return;

    final reason = _selectedReason == 'Other'
        ? _otherReasonController.text.trim()
        : _selectedReason!;

    if (reason.isEmpty) {
      _showSnackBar('Please enter the reason for cancellation.');
      return;
    }

    if (widget.bookingId.isEmpty) {
      _showSnackBar('Invalid booking ID.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId);
      final bookingSnapshot = await bookingRef.get();

      if (!bookingSnapshot.exists) {
        _showSnackBar('Booking not found. Invalid Booking ID.');
        return;
      }

      final bookingData = bookingSnapshot.data()!;
      final userId = bookingData['userId'];
      final slotId = bookingData['slotId'];

      await bookingRef.update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      final userBookingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .doc(widget.bookingId);

      await userBookingRef.update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      final dbService = DatabaseService();
      await dbService.cancelWheelsSlot(slotId, userId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmCanclePage()),
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRadioOption(String reason) {
    return RadioListTile<String>(
      title: Text(reason, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      activeColor: Colors.green,
      value: reason,
      groupValue: _selectedReason,
      onChanged: (String? value) {
        setState(() {
          _selectedReason = value;
          if (value != 'Other') {
            _otherReasonController.clear();
          }
        });
      },
    );
  }

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOtherSelected = _selectedReason == 'Other';

    return Scaffold(
      backgroundColor: const Color(0xFFB3CDE8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Cancel Parking Slot',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please select the reason for cancellations.',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 10),
              // ignore: unnecessary_to_list_in_spreads
              ..._reasons.map(_buildRadioOption).toList(),
              const SizedBox(height: 20),
              if (isOtherSelected) ...[
                const Text(
                  'Other',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otherReasonController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Enter your Reason',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _cancelBooking,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ).copyWith(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.deepPurple.withOpacity(0.5);
                      }
                      return null;
                    }),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Cancel Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Confirmation Screen
class ConfirmCanclePage extends StatelessWidget {
  const ConfirmCanclePage({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Go to Home', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
