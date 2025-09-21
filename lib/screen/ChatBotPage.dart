// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Add this import
// ignore: unused_import
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  // ignore: duplicate_ignore
  // ignore: library_private_types_in_public_api
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // AI Toolkit instance
  late final FlutterAIToolkit aiToolkit;

  @override
  void initState() {
    super.initState();
    aiToolkit = FlutterAIToolkit(apiKey: 'YOUR_OPENAI_API_KEY'); // <-- Replace with your API key
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await _firestore.collection("chat").add({
      "userId": userId,
      "text": text.trim(),
      "isBot": false,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _controller.clear();
    _getBotResponse(text.trim());
  }

  Future<void> _getBotResponse(String message) async {
    String response;
    final lowerMsg = message.toLowerCase();

    // Custom quick replies for known issues
    if (lowerMsg.contains("time")) {
      final bookings = await _firestore
          .collection("bookings")
          .where("userId", isEqualTo: userId)
          .orderBy("startTime", descending: true)
          .limit(1)
          .get();

      if (bookings.docs.isNotEmpty) {
        final data = bookings.docs.first.data();
        final DateTime startTime = data['startTime'].toDate();
        final Duration duration = DateTime.now().difference(startTime);
        response = "⏱️ You have been parked for ${duration.inMinutes} minutes.";
      } else {
        response = "🚫 You don't have any active bookings at the moment.";
      }
    } else if (lowerMsg.contains("help") ||
        lowerMsg.contains("support") ||
        lowerMsg.contains("assist")) {
      response = "🆘 I can assist you with:\n"
          "- 📍 Booking a spot\n"
          "- ⏱️ Parking duration\n"
          "- 💳 Payment issues\n"
          "- 🚪 Entry/Exit QR problems\n"
          "Just type your question!";
    } else if (lowerMsg.contains("payment")) {
      response = "💳 For payment issues, please ensure your transaction completed and was updated in the 'Payment' section. Let me know if you faced a failure.";
    } else if (lowerMsg.contains("book")) {
      response = "📍 You can book a spot by going to the 'Parking' section and selecting an available slot.";
    } else if (lowerMsg.contains("cancel")) {
      response = "❌ To cancel your booking, open the 'My Bookings' page and tap the cancel icon next to the active booking.";
    } else if (lowerMsg.contains("entry") || lowerMsg.contains("qr")) {
      response = "🔐 If you're having trouble with QR code entry, ensure your screen brightness is high and the code isn't blurry. Need help regenerating it?";
    } else {
      // Use AI Toolkit for general questions
      response = await _getAiReply(message);
    }

    await _firestore.collection("chat").add({
      "userId": userId,
      "text": response,
      "isBot": true,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // Use flutter_ai_toolkit to get AI reply
  Future<String> _getAiReply(String prompt) async {
    try {
      final aiResponse = await aiToolkit.completeText(
        prompt: prompt,
        maxTokens: 60,
        temperature: 0.7,
      );
      return aiResponse.text.trim();
    } catch (e) {
      return "🤖 Sorry, I couldn't process your request right now. Please try again later.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ChatBot Assistant")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("chat")
                  .where("userId", isEqualTo: userId)
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final isBot = data['isBot'] as bool;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      child: Align(
                        alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isBot ? Colors.grey[200] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isBot) const Icon(Icons.smart_toy, size: 18, color: Colors.black54),
                              if (isBot) const SizedBox(width: 6),
                              Flexible(child: Text(data['text'])),
                              if (!isBot) const SizedBox(width: 6),
                              if (!isBot) const Icon(Icons.person, size: 18, color: Colors.black54),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask the assistant...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FlutterAIToolkit {
  final String apiKey;

  FlutterAIToolkit({required this.apiKey});

  // Dummy implementation for completeText to avoid errors
  Future<_AIResponse> completeText({
    required String prompt,
    int maxTokens = 60,
    double temperature = 0.7,
  }) async {
    // Replace this with actual API call logic
    return _AIResponse(text: "This is a dummy AI response.");
  }
}

class _AIResponse {
  final String text;
  _AIResponse({required this.text});
}
// Note: Replace
// 'YOUR_OPENAI_API_KEY' with your actual OpenAI API key.
// The FlutterAIToolkit class is a placeholder and should be replaced with actual implementation for AI responses.
// Ensure you have the necessary permissions and configurations for Firestore and AI Toolkit in your project.