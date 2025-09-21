import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms & Conditions',
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
1. Acceptance of Terms
By using the SmartPark app, you agree to comply with these Terms and Conditions. If you do not agree, please do not use the app.

2. Use of the App
- You must be at least 18 years old to use this app.
- You are responsible for maintaining the confidentiality of your account credentials.
- You agree not to use the app for any unlawful purposes.

3. Parking Bookings
- Bookings are subject to availability.
- SmartPark is not responsible for any damages to vehicles during parking.
- Cancellations must be made within the app as per the cancellation policy.

4. Payments
- All payments must be made through the app using a valid payment method.
- Refunds, if applicable, will be processed as per our refund policy.

5. Limitation of Liability
SmartPark is not liable for any indirect, incidental, or consequential damages arising from the use of the app.

6. Changes to Terms
We may update these Terms and Conditions from time to time. You will be notified of any changes via the app.

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