// ignore: file_names
// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'MapScreen.dart';
import 'package:final_pro/screen/profilepage.dart';
import 'package:final_pro/screen/CarSlotSelectPage.dart';
import 'package:final_pro/screen/VanSlotSelectPage.dart';
import 'package:final_pro/screen/WheelsSlotSelectPage.dart'; // Import WheelsSlotSelectPage
// ignore: unused_import
import 'package:final_pro/screen/MotoSlotSelectPage.dart';
 // Import MotoSlotSelectPage
// import 'package:final_pro/Drawerscreen/.dart'; // Import BookSpotPage
import 'package:final_pro/screen/DrawerScreen.dart'; // Import DrawerScreen
import 'QRCodeScreen.dart'; // Import QRCodeScreen
import 'package:final_pro/screen/Notification_screen.dart';
// ignore: unused_import
import 'package:final_pro/screen/ExCarSlotSelectPage.dart';
import 'package:final_pro/screen/ExVanSlotSelectPage.dart';
import 'package:final_pro/screen/ExWheelsSlotSelectPage.dart'; // Import WheelsSlotSelectsPage
import 'package:final_pro/screen/ExMotoSlotSelectPage.dart';
 // Import MotoSlotSelectsPage
// Import ChatService

// Ensure MotoSlotSelectPage is defined in the imported file or define it here if missing


void main() {
  runApp(const ParkSpotApp());
}

class ParkSpotApp extends StatelessWidget {
  const ParkSpotApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Spot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  static List<Widget> _pagesBuilder(User? user) => [
    const HomeContent(),
    const MapScreen(),
    QRCodeScreen(data: user?.uid ?? 'No Data'), // <-- Add this
    const ProfilePage(),
    
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _pagesBuilder(user);
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
// Removed misplaced drawer code
  final List<SalomonBottomBarItem> _items = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text('Home'),
      selectedColor: Colors.blue,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.map),
      title: const Text('Map'),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.qr_code), // <-- Add this
      title: const Text('QR'),
      selectedColor: Colors.teal,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.account_circle),
      title: const Text('Profile'),
      selectedColor: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      drawer: DrawerScreen(
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index; // Update the selected index
          });
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7AB7DA), // Blue middle
              Color(0xFF84CDEE), // Dark blue bottom
            ],
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(height: 90),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SalomonBottomBar(
                    backgroundColor: Colors.transparent,
                    items: _items,
                    currentIndex: _selectedIndex,
                    onTap: _onTabChange,
                    selectedItemColor: Colors.blue,
                    // ignore: deprecated_member_use
                    unselectedItemColor: Colors.black.withOpacity(0.6),
                    itemShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: const Text('Home'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hi, find the best parking spots',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    // ignore: deprecated_member_use
                    fillColor: Colors.white.withOpacity(0.7),
                    filled: true,
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Your Vehicle Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final vehicles = [
                        VehicleCard(
                          vehicleName: 'Car',
                          lottieUrl: 'https://lottie.host/0c07e1d3-a021-4f23-921d-00489403051a/LfOxB8vOcE.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarSlotSelectPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Van',
                          lottieUrl: 'https://lottie.host/93a2cb20-2727-4ec8-8ea3-bb245d38f28e/raaF0oYUgG.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VanSlotSelectPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Three Wheels',
                          lottieUrl: 'https://lottie.host/e714d049-a3ea-4ca3-897e-3724ab786649/CwTONnK6u7.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WheelsSlotSelectPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Motor Cycle',
                          lottieUrl: 'https://lottie.host/8c0e6de5-18f1-43e7-9a23-1ba503fa41d8/26gb0p8eS2.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MotoSlotSelectPage(),
                              ),
                            );
                          },
                        ),
                      ];
                      return vehicles[index];
                    },
                  ),
                ),const SizedBox(height: 16),
                const Text(
                  'Can you Select Parking Issue Have Time to Park',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (context, index) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final vehicles = [
                        VehicleCard(
                          vehicleName: 'Car',
                          lottieUrl: 'https://lottie.host/0c07e1d3-a021-4f23-921d-00489403051a/LfOxB8vOcE.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarSlotSelectsPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Van',
                          lottieUrl: 'https://lottie.host/93a2cb20-2727-4ec8-8ea3-bb245d38f28e/raaF0oYUgG.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VanSlotSelectsPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Three Wheels',
                          lottieUrl: 'https://lottie.host/e714d049-a3ea-4ca3-897e-3724ab786649/CwTONnK6u7.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WheelsSlotSelectsPage(),
                              ),
                            );
                          },
                        ),
                        VehicleCard(
                          vehicleName: 'Motor Cycle',
                          lottieUrl: 'https://lottie.host/8c0e6de5-18f1-43e7-9a23-1ba503fa41d8/26gb0p8eS2.json',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MotoSlotSelectsPage(),
                              ),
                            );
                          },
                        ),
                      ];
                      return vehicles[index];
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Main Mall Parking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: fm.FlutterMap(
                      options: fm.MapOptions(
                        initialCenter: LatLng(6.9271, 79.8612), // Main Mall Parking location
                        initialZoom: 16.0,
                        interactionOptions: const fm.InteractionOptions(
                          flags: fm.InteractiveFlag.none, // Disable gestures for preview
                        ),
                      ),
                      children: [
                        fm.TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.smartpark',
                        ),
                        fm.MarkerLayer(
                          markers: [
                            fm.Marker(
                              width: 40.0,
                              height: 40.0,
                              point: LatLng(6.9271, 79.8612),
                              child: Icon(Icons.location_on, color: Colors.red, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final String vehicleName;
  final String? imagePath;
  final String? lottieUrl;
  final VoidCallback? onTap;

  const VehicleCard({
    required this.vehicleName,
    this.imagePath,
    this.lottieUrl,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: 120,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          // ignore: deprecated_member_use
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieUrl != null)
              Lottie.network(
                lottieUrl!,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              )
            else if (imagePath != null)
              Image.asset(
                imagePath!,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 8),
            Text(
              vehicleName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 30,
              width: 50,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.black.withOpacity(0.2)),
              ),
              child: const Center(
                child: Icon(Icons.double_arrow, size: 20, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

