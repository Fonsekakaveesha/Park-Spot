// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_pro/screen/EditProfile.dart';
import 'package:final_pro/screen/terms_conditions_screen.dart';
import 'package:final_pro/screen/privaty_police_screen.dart';
import 'package:final_pro/screen/help_suppot.dart';
import 'package:final_pro/services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseService dbService = DatabaseService();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _email = '';
  String _phone = '';
  String _gender = '';
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await dbService.getUserProfile(user.uid);
    final data = doc.data();

    if (data != null) {
      setState(() {
        _name = data['name'] ?? '';
        _email = user.email ?? '';
        _phone = data['phone'] ?? '';
        _gender = data['gender'] ?? '';
        _imagePath = data['imagePath'];

        if (_imagePath != null && _imagePath!.isNotEmpty) {
          _profileImage = null; // For network image fallback
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        _imagePath = pickedFile.path;
      });
      // Optional: Upload image and update Firestore if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    name: _name,
                    phone: _phone,
                    gender: _gender,
                    imagePath: _imagePath ?? '',
                  ),
                ),
              );
              if (updated == true) {
                _fetchProfile();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_imagePath != null && _imagePath!.isNotEmpty
                        ? NetworkImage(_imagePath!)
                        : null) as ImageProvider<Object>?,
                child: _profileImage == null && (_imagePath == null || _imagePath!.isEmpty)
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(_name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(_email, style: const TextStyle(fontSize: 16)),
            Text(_phone, style: const TextStyle(fontSize: 16)),
            Text(_gender, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            _buildProfileOption(Icons.wallet, 'Wallet'),
            _buildProfileOption(Icons.directions_car, 'My Vehicle'),
            _buildProfileOption(Icons.policy, 'Privacy Policy'),
            _buildProfileOption(Icons.support, 'Help & Support'),
            _buildProfileOption(Icons.language, 'Language'),
            _buildProfileOption(Icons.article, 'Terms & Condition'),
            _buildProfileOption(Icons.settings, 'App Settings'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Or navigate to login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, size: 30),
      title: Text(text, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        if (text == 'Terms & Condition') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TermsConditionsScreen()));
        } else if (text == 'Privacy Policy') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
        } else if (text == 'Help & Support') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportScreen()));
        }
        // Add more navigation logic as needed
      },
    );
  }
}
