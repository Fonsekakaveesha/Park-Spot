import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '''
1. Introduction
At SmartPark, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your data.

2. Information We Collect
- Personal Information: Name, email, phone number, and payment details.
- Vehicle Information: Vehicle type and number plate.
- Usage Data: App usage patterns and location data for parking purposes.

3. How We Use Your Information
- To provide and improve our parking services.
- To process payments and manage bookings.
- To communicate with you about your account and updates.

4. Data Sharing
We do not share your personal information with third parties except:
- With service providers for payment processing.
- As required by law or to protect our rights.

5. Data Security
We use industry-standard measures to protect your data, but no method is 100% secure.

6. Your Rights
- You can access, update, or delete your personal information via the app.
- Contact us at support@smartpark.com to exercise your rights.

7. Changes to This Policy
We may update this Privacy Policy periodically. Changes will be notified via the app.

For any questions, contact us at support@smartpark.com.
                    ''',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}