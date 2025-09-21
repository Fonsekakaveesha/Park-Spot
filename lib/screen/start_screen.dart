import 'package:final_pro/screen/LanguageScreen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const ParkSpotApp());
}

class ParkSpotApp extends StatelessWidget {
  const ParkSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Spot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const StartScreen(),
      routes: {
        '/language': (context) => const LanguageScreen(), // Dummy screen
      },
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void onGetStartedPressed(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/language');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Get Started Pressed')));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_parking_rounded,
                          color: Colors.black,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Vehicle Parking',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_pin,
                          color: Colors.redAccent,
                          size: 26,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Park Spot',
                          style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.car_rental,
                      color: Colors.black87,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Car illustration
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: size.width * 0.7,
                          height: size.width * 0.7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color(0xFFE6F1F6),
                                Color(0xFF7AB7DA),
                                Color(0xFF84CDEE),
                              ],
                              stops: [0.2, 1.0],
                              center: Alignment.center,
                              radius: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width * 0.6,
                          height: size.width * 0.6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // ignore: deprecated_member_use
                            color: Colors.blueAccent.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.blueAccent.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        Lottie.network(
                          'https://lottie.host/fa808d50-6962-4a25-9907-6a69c1da25fa/y0k4u0Fw0b.json',
                          width: size.width * 0.5,
                          fit: BoxFit.contain,
                          // ignore: unnecessary_underscores
                          errorBuilder:
                              // ignore: unnecessary_underscores
                              (_, __, ___) => const Icon(
                                Icons.directions_car,
                                size: 100,
                                color: Colors.grey,
                              ),
                        ),
                        Positioned(
                          top: size.width * 0.15,
                          child: Transform.rotate(
                            angle: 0.4,
                            child: Container(
                              width: size.width * 0.25,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    Colors.blueAccent.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title & subtitle
                const SizedBox(height: 20),
                const Text(
                  'Find The Best Car.\nParking Spot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find the best parking spot, every time,\nwithout the parking hassle.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),

                // Navigate button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/language');
                  },
                  child: null,
                ),

                // Let's Get Started button
                Material(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () => onGetStartedPressed(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff7D79F6), Color(0xffBEBCF9)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black87),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Let's Get Started",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
