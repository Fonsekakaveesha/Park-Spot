// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_pro/screen/BookSpotPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WheelsSlot {
  final String id;
  final bool isBooked;
  final String? bookedBy; // Track who booked the slot

  WheelsSlot({required this.id, required this.isBooked, this.bookedBy});

  factory WheelsSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WheelsSlot(
      id: doc.id,
      isBooked: data['isBooked'] ?? false,
      bookedBy: data['bookedBy'],
    );
  }
}

class WheelsSlotSelectController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Default slots
  final List<WheelsSlot> defaultSlots = [
    WheelsSlot(id: 'B2', isBooked: false),
    WheelsSlot(id: 'B3', isBooked: false),
    WheelsSlot(id: 'B4', isBooked: false),
    WheelsSlot(id: 'B6', isBooked: false),
    WheelsSlot(id: 'B7', isBooked: false),
    WheelsSlot(id: 'B9', isBooked: false),
    WheelsSlot(id: 'C1', isBooked: false),
    WheelsSlot(id: 'C3', isBooked: false),
    WheelsSlot(id: 'C4', isBooked: false),
    WheelsSlot(id: 'C6', isBooked: false),
    WheelsSlot(id: 'C7', isBooked: false),
    WheelsSlot(id: 'C8', isBooked: false),
  ];

  RxList<WheelsSlot> slots = <WheelsSlot>[].obs;
  Rx<WheelsSlot?> selectedSlot = Rx<WheelsSlot?>(null);

  @override
  void onInit() {
    super.onInit();
    _listenToSlots();
  }

  void _listenToSlots() {
    _firestore.collection('wheels_slots').snapshots().listen((snapshot) {
      // Map Firestore slots by id
      final firestoreSlots = {
        for (var doc in snapshot.docs) doc.id: WheelsSlot.fromFirestore(doc)
      };
      // Merge with default slots
      slots.value = defaultSlots.map((slot) {
        return firestoreSlots[slot.id] ?? slot;
      }).toList();
    });
  }

  void selectSlot(WheelsSlot slot) {
    selectedSlot.value = slot;
  }

  Future<void> bookSelectedSlot() async {
    final slot = selectedSlot.value;
    if (slot == null) return;
    final docRef = _firestore.collection('wheels_slots').doc(slot.id);
    final user = _auth.currentUser;

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists && !(snapshot.data()?['isBooked'] ?? false)) {
        transaction.update(docRef, {
          'isBooked': true,
          'bookedBy': user?.uid,
        });
      } else {
        throw Exception('Slot already booked');
      }
    });
    // Clear selection after booking
    selectedSlot.value = null;
  }

  Future<void> cancelSelectedSlot() async {
    final slot = selectedSlot.value;
    if (slot == null) return;
    final docRef = _firestore.collection('wheels_slots').doc(slot.id);
    final user = _auth.currentUser;

    // Only allow the user who booked the slot to cancel
    final snapshot = await docRef.get();
    if (snapshot.exists &&
        (snapshot.data()?['isBooked'] ?? false) &&
        snapshot.data()?['bookedBy'] == user?.uid) {
      await docRef.update({
        'isBooked': false,
        'bookedBy': null,
      });
    } else {
      throw Exception('You can only cancel your own booking.');
    }
    // Clear selection after canceling
    selectedSlot.value = null;
  }
}

class WheelsSlotSelectsPage extends StatelessWidget {
  final WheelsSlotSelectController controller = Get.put(WheelsSlotSelectController());

  WheelsSlotSelectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFE5ECFB),
      appBar: AppBar(
        title: const Text('Select Parking Car Slot'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Entry', style: TextStyle(color: Colors.red, fontSize: 20)),
          ),
          Expanded(
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left side B slots
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.slots
                        .where((slot) => slot.id.startsWith('B'))
                        .map((slot) => SlotButton(
                              slot: slot,
                              onTap: () => controller.selectSlot(slot),
                              isSelected: controller.selectedSlot.value?.id == slot.id,
                              currentUserId: user?.uid,
                            ))
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) => const Icon(Icons.arrow_downward, size: 30)),
                    ),
                  ),
                  // Right side C slots
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: controller.slots
                        .where((slot) => slot.id.startsWith('C'))
                        .map((slot) => SlotButton(
                              slot: slot,
                              onTap: () => controller.selectSlot(slot),
                              isSelected: controller.selectedSlot.value?.id == slot.id,
                              currentUserId: user?.uid,
                            ))
                        .toList(),
                  ),
                ],
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Exit', style: TextStyle(color: Colors.red, fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final slot = controller.selectedSlot.value;
              final isBookedByMe = slot != null && slot.isBooked && slot.bookedBy == user?.uid;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: slot != null && !slot.isBooked
                        ? () async {
                            try {
                              await controller.bookSelectedSlot();
                              Get.snackbar(
                                'Success',
                                'Slot ${slot.id} booked successfully!',
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookSpotPage(
                                    slotId: slot.id,
                                  ),
                                ),
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Booking Failed',
                                e.toString(),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: const Color(0xFF9DBCFB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Book', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: isBookedByMe
                        ? () async {
                            try {
                              await controller.cancelSelectedSlot();
                              Get.snackbar(
                                'Cancelled',
                                'Slot ${slot.id} booking cancelled!',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                            } catch (e) {
                              Get.snackbar(
                                'Cancel Failed',
                                e.toString(),
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SlotButton extends StatelessWidget {
  final WheelsSlot slot;
  final VoidCallback onTap;
  final bool isSelected;
  final String? currentUserId;

  const SlotButton({
    super.key,
    required this.slot,
    required this.onTap,
    required this.isSelected,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    if (slot.isBooked) {
      buttonColor = slot.bookedBy == currentUserId ? Colors.orange : Colors.red;
    } else if (isSelected) {
      buttonColor = Colors.blue;
    } else {
      buttonColor = Colors.green;
    }

    return ElevatedButton(
      onPressed: slot.isBooked && slot.bookedBy != currentUserId ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        slot.id,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}