// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unused_import
import 'package:final_pro/screen/BookSpotPage.dart'; // Import BookSpotPage

class   MotoSlot {
  final String id;
  bool isBooked;

  MotoSlot({required this.id, this.isBooked = false});
}

class MotoSlotSelectController extends GetxController {
  RxList<MotoSlot> slots = <MotoSlot>[
    MotoSlot(id: 'B2'),
    MotoSlot(id: 'B3'),
    MotoSlot(id: 'B4'),
    MotoSlot(id: 'B6'),
    MotoSlot(id: 'B7'),
    MotoSlot(id: 'B9'),
    MotoSlot(id: 'C1'),
    MotoSlot(id: 'C3'),
    MotoSlot(id: 'C4'),
    MotoSlot(id: 'C6'),
    MotoSlot(id: 'C7'),
    MotoSlot(id: 'C8'),
  ].obs;

  Rx<MotoSlot?> selectedSlot = Rx<MotoSlot?>(null);

  void selectSlot(MotoSlot slot) {
    if (slot.isBooked) {
      Get.snackbar('Slot Booked', 'This slot is already booked by another car!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    selectedSlot.value = slot;
  }

  void clearSelectedSlot() {
    selectedSlot.value = null;
  }
}

class MotoSlotSelectsPage extends StatelessWidget {
  final MotoSlotSelectController controller = Get.put(MotoSlotSelectController());

  MotoSlotSelectsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                              isSelected: controller.selectedSlot.value == slot,
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
                              isSelected: controller.selectedSlot.value == slot,
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
            child: ElevatedButton(
              onPressed: () {
                if (controller.selectedSlot.value != null) {
                  // Navigate to BookSpotPage with Navigator.pushReplacement
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookSpotPage(
                        slotId: controller.selectedSlot.value!.id,
                      ),
                    ),
                  );
                } else {
                  Get.snackbar('No Slot Selected', 'Please select a slot first.',
                      backgroundColor: Colors.orange, colorText: Colors.white);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                backgroundColor: const Color(0xFF9DBCFB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}

class SlotButton extends StatelessWidget {
  final MotoSlot slot;
  final VoidCallback onTap;
  final bool isSelected;

  const SlotButton({super.key, required this.slot, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    if (slot.isBooked) {
      buttonColor = Colors.red;
    } else if (isSelected) {
      buttonColor = Colors.blue;
    } else {
      buttonColor = Colors.green;
    }

    return ElevatedButton(
      onPressed: onTap,
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

