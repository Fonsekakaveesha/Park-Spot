// ignore_for_file: file_names

import 'dart:ui';
import 'package:final_pro/screen/cctv_stream_screen.dart';
import 'package:flutter/material.dart';
import 'ParkingTimerScreen.dart'; // Import the ParkingTimerScreen
import 'package:final_pro/screen/PaymentScreen.dart'; // Import the PaymentScreen
import 'package:lottie/lottie.dart';
// ignore: duplicate_import
import 'package:final_pro/screen/cctv_stream_screen.dart'; // Import the CCTVStreamScreen
import 'package:final_pro/screen/ParkingTimer_screen.dart'; // Import the ParkingTimer_Screen
import 'package:final_pro/screen/BookingUpdate_screen.dart';
// Import the BookingUpdate_screen
import 'package:final_pro/screen/ChatBotPage.dart';
import 'package:final_pro/screen/ParkingPaymentScreen.dart';

class DrawerScreen extends StatefulWidget {
  final Function(int) onItemTapped;

  const DrawerScreen({super.key, required this.onItemTapped});

  @override
  // ignore: library_private_types_in_public_api
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Animation Controller for the rotation effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Rotate the drawer from 0 to 45 degrees
    _rotationAnimation = Tween<double>(begin: 0, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.rotationY(_rotationAnimation.value),
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: Stack(
          children: [
            // Glassy frosted effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1), // Glass effect
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Drawer content
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Lottie.network(
                      'https://lottie.host/fd76a9b4-fa20-4377-a559-4c1969e26b22/LKsTwFp6NW.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    widget.onItemTapped(0); // Navigate to Home
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text('Timer'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingTimerScreen(),
                      ),
                    ); // Navigate to ParkingTimerScreen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PaymentScreen(
                              slotId: '1',
                              amount: 0.0,
                              startTime: DateTime.now(),
                              endTime: DateTime.now().add(
                                const Duration(hours: 1),
                              ),
                            ),
                      ),
                    ); // Navigate to ParkingTimerScreen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_camera_back),
                  title: const Text('CCTV Events'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CCTVStreamScreen(),
                      ),
                    ); // Navigate to ParkingTimerScreen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_camera_back),
                  title: const Text('CCTV Events'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingTimer_Screen(),
                      ),
                    ); // Navigate to ParkingTimerScreen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmarks),
                  title: const Text('Booking Information'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingListScreen(),
                      ),
                    ); // Navigate to ParkingTimerScreen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text("Chat Assistant"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatBotPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment),
                  title: Text("Chat Assistant"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ParkingPaymentScreen(slotId: '1', userId: '1'),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.timer_10_select_outlined),
                  title: const Text('Time Payment'),
                  onTap: () {
                    widget.onItemTapped(2); // Navigate to Payment
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    widget.onItemTapped(3); // Navigate to Settings
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    // Handle logout action
                    Navigator.pop(context); // Close the drawer
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
