import 'package:final_pro/screen/auth_screen.dart';
// ignore: unused_import
import 'package:final_pro/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:final_pro/services/notification_service.dart'
    as notification_service;

// Screens
import 'package:final_pro/screen/splach_screen.dart';
import 'package:final_pro/screen/start_screen.dart';
import 'package:final_pro/screen/LanguageScreen.dart' as language_screen;
import 'package:final_pro/screen/welcome_back.dart';
import 'package:final_pro/auth/main_page.dart';
import 'package:final_pro/screen/verify_code.dart';
import 'package:final_pro/screen/phone_verification_screen.dart';
import 'package:final_pro/screen/completprofile_screen.dart';
import 'package:final_pro/screen/HomePage.dart';
import 'package:final_pro/screen/QRBookingScreen.dart';
import 'package:final_pro/screen/MapScreen.dart';
import 'package:final_pro/screen/profilepage.dart' as profile_page;
import 'package:final_pro/screen/EditProfile.dart';
import 'package:final_pro/screen/CarSlotSelectPage.dart' as car_slot;
import 'package:final_pro/screen/VanSlotSelectPage.dart';
import 'package:final_pro/screen/WheelsSlotSelectPage.dart';
import 'package:final_pro/screen/MotoSlotSelectPage.dart';
import 'package:final_pro/screen/BookSpotPage.dart' as book_spot;
import 'package:final_pro/screen/DrawerScreen.dart';
import 'package:final_pro/screen/ParkingTimerScreen.dart';
import 'package:final_pro/screen/PaymentScreen.dart';
import 'package:final_pro/screen/terms_conditions_screen.dart';
import 'package:final_pro/screen/help_suppot.dart';
import 'package:final_pro/screen/privaty_police_screen.dart';
import 'package:final_pro/screen/cctv_stream_screen.dart';
import 'package:final_pro/screen/Notification_screen.dart';
import 'package:final_pro/screen/ParkingTimer_screen.dart';
import 'package:final_pro/screen/TransactionSuccessScreen.dart';
import 'package:final_pro/screen/CancleBooking_screen.dart';
import 'package:final_pro/screen/BookingUpdate_screen.dart';
import 'package:final_pro/screen/ExCarSlotSelectPage.dart';
import 'package:final_pro/screen/ExVanSlotSelectPage.dart';
import 'package:final_pro/screen/ExWheelsSlotSelectPage.dart';
import 'package:final_pro/screen/ChatBotPage.dart';
import 'package:final_pro/screen/ParkingPaymentScreen.dart';

// Auth Screen (Single AuthScreen with toggle)
// ignore: unused_import
import 'package:final_pro/screen/signin_signout.dart'; // Your fixed AuthScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC0_w8CoVxtS-ZOlP-Y7wiQY4b8SXItBtA",
      appId: "1:1077572684685:android:fc318e760ab70624b24bc4",
      messagingSenderId: "1077572684685",
      projectId: "finalsmart-8a718",
    ),
  );

  // Initialize push notification service
  await notification_service.NotificationService.instance.initialize();
  _printFCMToken();

  runApp(const MyApp());
}

void _printFCMToken() async {
  final token =
      await notification_service.NotificationService.instance.getToken();
  // ignore: avoid_print
  print('🔑 FCM Token: $token');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Park Spot',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/start': (context) => const StartScreen(),
        '/language': (context) => const language_screen.LanguageScreen(),
        '/welcome_back': (context) => WelcomeBackScreen(),
        '/auth': (context) => const AuthScreen(), // Merged Sign In & Sign Up
        '/main_page': (context) => const MainPage(),
        '/verify_code':
            (context) => const VerifyCodeScreen(isEmailVerification: true),
        '/phone_verification':
            (context) => const PhoneVerificationScreen(phoneNumber: ''),
        '/complet_screen': (context) => const CompleteProfileScreen(),
        '/home_screen': (context) => const HomePage(),
        '/qr_booking': (context) => const QRCodeScannerScreen(),
        '/map_screen': (context) => const MapScreen(),
        '/profile_screen': (context) => const profile_page.ProfilePage(),
        '/edit_profile':
            (context) => const EditProfilePage(
              name: '',
              phone: '',
              gender: '',
              imagePath: '',
            ),
        '/car_slot_select': (context) => car_slot.CarSlotSelectPage(),
        '/van_slot_select': (context) => VanSlotSelectPage(),
        '/wheels_slot_select': (context) => WheelsSlotSelectPage(),
        '/moto_slot_select': (context) => MotoSlotSelectPage(),
        '/book_spot':
            (context) => book_spot.BookSpotPage(slotId: 'defaultSlotId'),
        '/drawer': (context) => DrawerScreen(onItemTapped: (int index) {}),
        '/parking_timer': (context) => ParkingTimerScreen(),
        '/payment':
            (context) => PaymentScreen(
              slotId: 'defaultSlotId',
              amount: 0.0,
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 1)),
            ),
        '/terms_conditions': (context) => const TermsConditionsScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/help_support': (context) => const HelpSupportScreen(),
        '/cctv_stream': (context) => CCTVStreamScreen(),
        '/notification_screen': (context) => const NotificationScreen(),
        '/ParkingTimer_screen': (context) => const ParkingTimer_Screen(),
        '/transaction_success': (context) => const TransactionSuccessScreen(),
        '/cancel_booking': (context) => CancelBookingScreen(bookingId: ''),
        '/booking_update': (context) => const BookingListScreen(),
        '/EXCarSlotSelectPage': (context) => CarSlotSelectsPage(),
        '/EXVanSlotSelectPage': (context) => VanSlotSelectsPage(),
        '/EXWheelsSlotSelectPage': (context) => WheelsSlotSelectsPage(),
        '/chat_bot': (context) => const ChatBotPage(),
        '/parking_payment':
            (context) => const ParkingPaymentScreen(slotId: '1', userId: '1'),
      },
    );
  }
}
