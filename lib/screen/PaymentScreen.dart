// ignore_for_file: file_names, sort_child_properties_last, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:final_pro/screen/HomePage.dart';

class PaymentScreen extends StatefulWidget {
  final String slotId;
  final double amount;
  final DateTime startTime;
  final DateTime endTime;

  const PaymentScreen({
    super.key,
    required this.slotId,
    required this.amount,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, String>? savedCard;

  Future<void> savePaymentDetails(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final booking = {
        'userId': user.uid,
        'slotId': widget.slotId,
        'amount': widget.amount,
        'startTime': widget.startTime,
        'endTime': widget.endTime,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
        'card': savedCard?['cardNumber'] ?? '',
        'isOverdue': false,
      };

      await FirebaseFirestore.instance.collection('payments').add(booking);
    }
  }

  void _navigateToAddCard() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );
    if (result != null) {
      setState(() {
        savedCard = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cash Payment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Cash'),
                  trailing: Icon(Icons.check_circle),
                ),
                const Divider(),
                const Text(
                  'Credit & Debit Card',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                savedCard == null
                    ? GestureDetector(
                      onTap: _navigateToAddCard,
                      child: const ListTile(
                        leading: Icon(Icons.credit_card),
                        title: Text('Add Card'),
                        trailing: Icon(Icons.arrow_forward),
                      ),
                    )
                    : ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: Text(
                        '**** **** **** ${savedCard!['cardNumber']!.substring(savedCard!['cardNumber']!.length - 4)}',
                      ),
                      subtitle: Text('Exp: ${savedCard!['expiryDate']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _navigateToAddCard,
                      ),
                    ),
                const Divider(),
                const Text(
                  'More Payment Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const ListTile(
                  leading: Icon(Icons.account_balance_wallet),
                  title: Text('Paypal'),
                  trailing: Icon(Icons.check_circle),
                ),
                const ListTile(
                  leading: Icon(Icons.phone_iphone),
                  title: Text('Apple Pay'),
                  trailing: Icon(Icons.check_circle),
                ),
                const ListTile(
                  leading: Icon(Icons.android),
                  title: Text('Google Pay'),
                  trailing: Icon(Icons.check_circle),
                ),
                const SizedBox(height: 20),
                Lottie.network(
                  'https://lottie.host/e6114be1-27ae-46df-a817-b99b2003c622/bodxz2PwKY.json',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await savePaymentDetails(context);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentSuccessScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('Confirm Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  void _saveCard() {
    if (holderNameController.text.isNotEmpty &&
        cardNumberController.text.isNotEmpty &&
        expiryDateController.text.isNotEmpty &&
        cvvController.text.isNotEmpty) {
      Navigator.pop(context, {
        'holderName': holderNameController.text,
        'cardNumber': cardNumberController.text,
        'expiryDate': expiryDateController.text,
        'cvv': cvvController.text,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all card details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit & Debit Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Lottie.network(
                  'https://lottie.host/ff9370c2-aa3e-466c-b39d-f371dc93b2a0/llsGBP3mIl.json',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: holderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryDateController,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date (MM/YY)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        decoration: const InputDecoration(
                          labelText: 'CVV',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveCard,
                  child: const Text('Save Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(50),
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

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  void generatePDFReceipt(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Center(
              child: pw.Text(
                "Your Parking Receipt\nSlot: ABC123\nAmount: \$200.00",
              ),
            ),
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'receipt.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F1F6), Color(0xFF7AB7DA), Color(0xFF84CDEE)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                  'https://lottie.host/f6cc9842-54e3-40be-8dd0-ff772d5f4f8c/0IUjDIJa6O.json',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your Parking Slot Successfully Booked.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                const Text(
                  'You can check your booking on the Home Menu.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => generatePDFReceipt(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Download E-Receipt',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View E-Ticket',
                    style: TextStyle(color: Colors.blue),
                  ),
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
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 18),
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
