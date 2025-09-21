// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_pro/screen/BookSpotPage.dart';
import 'package:final_pro/services/database_service.dart';

class WheelsSlotSelectController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  final List<WheelsSlot> defaultSlots = [
    WheelsSlot(id: 'B2', isBooked: false),
    WheelsSlot(id: 'B3', isBooked: false),
    WheelsSlot(id: 'B4', isBooked: true),
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
    _dbService.getWheelsSlotsStream().listen((firestoreSlots) async {
      for (var slot in firestoreSlots) {
        if (slot.isBooked &&
            slot.endTime != null &&
            DateTime.now().isAfter(slot.endTime!)) {
          await _dbService.releaseExpiredWheelsSlot(slot.id);
        }
      }
      final slotMap = {for (var slot in firestoreSlots) slot.id: slot};
      slots.value =
          defaultSlots.map((slot) => slotMap[slot.id] ?? slot).toList();
    });
  }

  void selectSlot(WheelsSlot slot) {
    selectedSlot.value = slot;
  }

  Future<void> cancelSelectedSlot() async {
    final slot = selectedSlot.value;
    final user = _auth.currentUser;
    if (slot == null || user == null) return;
    await _dbService.cancelWheelsSlot(slot.id, user.uid);
    selectedSlot.value = null;
  }
}

class WheelsSlotSelectPage extends StatelessWidget {
  final WheelsSlotSelectController controller = Get.put(
    WheelsSlotSelectController(),
  );

  WheelsSlotSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFE5ECFB),
      appBar: AppBar(
        title: const Text('Select Parking Wheels Slot'),
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
            child: Text(
              'Entry',
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
          Expanded(
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        controller.slots
                            .where((slot) => slot.id.startsWith('B'))
                            .map(
                              (slot) => SlotButton(
                                slot: slot,
                                onTap: () => controller.selectSlot(slot),
                                isSelected:
                                    controller.selectedSlot.value?.id ==
                                    slot.id,
                                currentUserId: user?.uid,
                              ),
                            )
                            .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (index) => const Icon(Icons.arrow_downward, size: 30),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        controller.slots
                            .where((slot) => slot.id.startsWith('C'))
                            .map(
                              (slot) => SlotButton(
                                slot: slot,
                                onTap: () => controller.selectSlot(slot),
                                isSelected:
                                    controller.selectedSlot.value?.id ==
                                    slot.id,
                                currentUserId: user?.uid,
                              ),
                            )
                            .toList(),
                  ),
                ],
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Exit',
              style: TextStyle(color: Colors.red, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              final slot = controller.selectedSlot.value;
              final isBookedByMe =
                  slot != null && slot.isBooked && slot.bookedBy == user?.uid;
              final isExpired =
                  slot != null &&
                  slot.endTime != null &&
                  DateTime.now().isAfter(slot.endTime!);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:
                        slot != null && (!slot.isBooked || isExpired)
                            ? () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          BookSpotPage(slotId: slot.id),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      backgroundColor: const Color(0xFF9DBCFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Book', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed:
                        isBookedByMe
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
