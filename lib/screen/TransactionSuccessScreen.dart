// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TransactionSuccessScreen extends StatelessWidget {
  // ignore: use_super_parameters
  const TransactionSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data, typically passed in constructor
    const duration = "3 HOURS";
    const date = "14 MAY, 2018";
    const destination = "MALL OF INDIA";
    const amount = "RS 160.50";
    const status = "COMPLETED";
    const cardType = "VISA";
    const cardInfo = "Visa Card ending **67";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top half with purple curved background
          ClipPath(
            clipper: _TopClipper(),
            child: Container(
              height: 220,
              color: Colors.deepPurpleAccent,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Thank you!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Transaction was successful',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Circle with car icon
          Container(
            margin: const EdgeInsets.only(top: -40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.deepPurpleAccent,
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 36,
              child: Icon(Icons.directions_car_filled, size: 48, color: Colors.deepPurpleAccent),
            ),
          ),

          const SizedBox(height: 20),

          // Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                _infoRow('TIME DURATION', duration, TextAlign.left),
                _infoRow('DATE', date, TextAlign.right),
                const SizedBox(height: 8),
                _infoRow('TO', destination, TextAlign.left),
                const SizedBox(height: 8),
                _infoRow('AMOUNT', amount, TextAlign.left),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      status,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Debit Card info box
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          cardType,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    title: Text(cardInfo),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, TextAlign align) {
    return Row(
      mainAxisAlignment: align == TextAlign.left ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (align == TextAlign.left)
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        if (align == TextAlign.right)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}

class _TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveHeight = 70;

    Path path = Path();
    path.lineTo(0, size.height - curveHeight);

    var firstControlPoint = Offset(size.width / 2, size.height + curveHeight);
    var firstEndPoint = Offset(size.width, size.height - curveHeight);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}