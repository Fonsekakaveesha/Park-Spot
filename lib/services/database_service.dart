import 'package:cloud_firestore/cloud_firestore.dart';

// --- WheelsSlot Model ---
class WheelsSlot {
  final String id;
  final bool isBooked;
  final String? bookedBy;
  final DateTime? startTime;
  final DateTime? endTime;

  WheelsSlot({
    required this.id,
    required this.isBooked,
    this.bookedBy,
    this.startTime,
    this.endTime,
  });

  factory WheelsSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WheelsSlot(
      id: doc.id,
      isBooked: data['isBooked'] ?? false,
      bookedBy: data['bookedBy'],
      startTime:
          data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : null,
      endTime:
          data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : null,
    );
  }
}

// --- CarSlot Model ---
class CarSlot {
  final String id;
  final bool isBooked;
  final String? bookedBy;
  final DateTime? startTime;
  final DateTime? endTime;

  CarSlot({
    required this.id,
    required this.isBooked,
    this.bookedBy,
    this.startTime,
    this.endTime,
  });

  factory CarSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarSlot(
      id: doc.id,
      isBooked: data['isBooked'] ?? false,
      bookedBy: data['bookedBy'],
      startTime:
          data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : null,
      endTime:
          data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : null,
    );
  }

  CarSlot copyWith({
    String? id,
    bool? isBooked,
    String? bookedBy,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return CarSlot(
      id: id ?? this.id,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

// --- VanSlot Model ---
class VanSlot {
  final String id;
  final bool isBooked;
  final String? bookedBy;
  final DateTime? startTime;
  final DateTime? endTime;

  VanSlot({
    required this.id,
    required this.isBooked,
    this.bookedBy,
    this.startTime,
    this.endTime,
  });

  factory VanSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VanSlot(
      id: doc.id,
      isBooked: data['isBooked'] ?? false,
      bookedBy: data['bookedBy'],
      startTime:
          data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : null,
      endTime:
          data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : null,
    );
  }

  VanSlot copyWith({
    String? id,
    bool? isBooked,
    String? bookedBy,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return VanSlot(
      id: id ?? this.id,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

// --- MotoSlot Model ---
class MotoSlot {
  final String id;
  final bool isBooked;
  final String? bookedBy;
  final DateTime? startTime;
  final DateTime? endTime;

  MotoSlot({
    required this.id,
    required this.isBooked,
    this.bookedBy,
    this.startTime,
    this.endTime,
  });

  factory MotoSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MotoSlot(
      id: doc.id,
      isBooked: data['isBooked'] ?? false,
      bookedBy: data['bookedBy'],
      startTime:
          data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : null,
      endTime:
          data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : null,
    );
  }

  MotoSlot copyWith({
    String? id,
    bool? isBooked,
    String? bookedBy,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return MotoSlot(
      id: id ?? this.id,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

// --- DatabaseService ---
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // USER PROFILE METHODS
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String uid,
  ) async {
    return await _db.collection('users').doc(uid).get();
  }

  // BOOKINGS
  Future<void> addSlotBooking(String uid, Map<String, dynamic> data) async {
    final bookingRef = await _db.collection('bookings').add(data);
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingRef.id)
        .set(data);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserBookings(
    String uid,
  ) async {
    return await _db.collection('users').doc(uid).collection('bookings').get();
  }

  Future<void> cancelBooking(String uid, String bookingId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId)
        .update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // PAYMENTS
  Future<DocumentReference> addPayment(
    String uid,
    Map<String, dynamic> data,
  ) async {
    return await _db
        .collection('users')
        .doc(uid)
        .collection('payments')
        .add(data);
  }

  Future<List<Map<String, dynamic>>> getPayments(String uid) async {
    final snapshot =
        await _db.collection('users').doc(uid).collection('payments').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> updatePayment(
    String uid,
    String paymentId,
    Map<String, dynamic> data,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('payments')
        .doc(paymentId)
        .update(data);
  }

  Future<void> deletePayment(String uid, String paymentId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('payments')
        .doc(paymentId)
        .delete();
  }

  // EMPLOYEE DETAILS
  Future<String> addEditProfileEmployeeDetails(
    Map<String, dynamic> employeeData,
  ) async {
    try {
      await _db.collection('employees').add(employeeData);
      return 'Employee details added successfully';
    } catch (e) {
      return 'Error adding employee details: $e';
    }
  }

  // --- SLOT LOGIC WITH TIME-BASED BOOKING ---

  // --- Wheels Slot ---
  Stream<List<WheelsSlot>> getWheelsSlotsStream() {
    return _db.collection('wheels_slots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => WheelsSlot.fromFirestore(doc)).toList();
    });
  }

  Future<void> releaseExpiredWheelsSlot(String slotId) async {
    final docRef = _db.collection('wheels_slots').doc(slotId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isBooked'] == true && data['endTime'] != null) {
        final bookingEnd = (data['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(bookingEnd)) {
          await docRef.update({
            'isBooked': false,
            'bookedBy': null,
            'startTime': null,
            'endTime': null,
          });
        }
      }
    }
  }

  Future<void> bookWheelsSlot(
    String slotId,
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final available = await isSlotAvailable(slotId, startTime, endTime);
    if (!available) {
      throw Exception('This slot is already booked for the selected time.');
    }
    await _db.collection('wheels_slots').doc(slotId).update({
      'isBooked': true,
      'bookedBy': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    });
  }

  Future<void> cancelWheelsSlot(String slotId, String userId) async {
    final docRef = _db.collection('wheels_slots').doc(slotId);
    final snapshot = await docRef.get();
    if (snapshot.exists &&
        (snapshot['isBooked'] ?? false) &&
        snapshot['bookedBy'] == userId) {
      await docRef.update({
        'isBooked': false,
        'bookedBy': null,
        'startTime': null,
        'endTime': null,
      });
    } else {
      throw Exception('You can only cancel your own booking.');
    }
  }

  // --- Car Slot ---
  Stream<List<CarSlot>> getCarSlotsStream() {
    return _db.collection('car_slots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarSlot.fromFirestore(doc)).toList();
    });
  }

  Future<void> releaseExpiredCarSlot(String slotId) async {
    final docRef = _db.collection('car_slots').doc(slotId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isBooked'] == true && data['endTime'] != null) {
        final bookingEnd = (data['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(bookingEnd)) {
          await docRef.update({
            'isBooked': false,
            'bookedBy': null,
            'startTime': null,
            'endTime': null,
          });
        }
      }
    }
  }

  Future<bool> isSlotAvailable(
    String slotId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final query =
        await _db
            .collection('bookings')
            .where('slotId', isEqualTo: slotId)
            .where('status', isEqualTo: 'booked')
            .get();

    for (var doc in query.docs) {
      final existingStart = (doc['startDateTime'] as Timestamp).toDate();
      final existingEnd = (doc['endDateTime'] as Timestamp).toDate();
      // Check for time overlap
      if (startTime.isBefore(existingEnd) && endTime.isAfter(existingStart)) {
        return false;
      }
    }
    return true;
  }

  Future<void> bookCarSlot(
    String slotId,
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final available = await isSlotAvailable(slotId, startTime, endTime);
    if (!available) {
      throw Exception('This slot is already booked for the selected time.');
    }
    await _db.collection('car_slots').doc(slotId).update({
      'isBooked': true,
      'bookedBy': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    });
  }

  Future<void> cancelCarSlot(String slotId, String userId) async {
    final docRef = _db.collection('car_slots').doc(slotId);
    final snapshot = await docRef.get();
    if (snapshot.exists &&
        (snapshot['isBooked'] ?? false) &&
        snapshot['bookedBy'] == userId) {
      await docRef.update({
        'isBooked': false,
        'bookedBy': null,
        'startTime': null,
        'endTime': null,
      });
    } else {
      throw Exception('You can only cancel your own booking.');
    }
  }

  // --- Van Slot ---
  Stream<List<VanSlot>> getVanSlotsStream() {
    return _db.collection('van_slots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VanSlot.fromFirestore(doc)).toList();
    });
  }

  Future<void> releaseExpiredVanSlot(String slotId) async {
    final docRef = _db.collection('van_slots').doc(slotId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isBooked'] == true && data['endTime'] != null) {
        final bookingEnd = (data['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(bookingEnd)) {
          await docRef.update({
            'isBooked': false,
            'bookedBy': null,
            'startTime': null,
            'endTime': null,
          });
        }
      }
    }
  }

  Future<void> bookVanSlot(
    String slotId,
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final available = await isSlotAvailable(slotId, startTime, endTime);
    if (!available) {
      throw Exception('This slot is already booked for the selected time.');
    }
    await _db.collection('van_slots').doc(slotId).update({
      'isBooked': true,
      'bookedBy': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    });
  }

  Future<void> cancelVanSlot(String slotId, String userId) async {
    final docRef = _db.collection('van_slots').doc(slotId);
    final snapshot = await docRef.get();
    if (snapshot.exists &&
        (snapshot['isBooked'] ?? false) &&
        snapshot['bookedBy'] == userId) {
      await docRef.update({
        'isBooked': false,
        'bookedBy': null,
        'startTime': null,
        'endTime': null,
      });
    } else {
      throw Exception('You can only cancel your own booking.');
    }
  }

  // --- Moto Slot ---
  Stream<List<MotoSlot>> getMotoSlotsStream() {
    return _db.collection('moto_slots').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MotoSlot.fromFirestore(doc)).toList();
    });
  }

  Future<void> releaseExpiredMotoSlot(String slotId) async {
    final docRef = _db.collection('moto_slots').doc(slotId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['isBooked'] == true && data['endTime'] != null) {
        final bookingEnd = (data['endTime'] as Timestamp).toDate();
        if (DateTime.now().isAfter(bookingEnd)) {
          await docRef.update({
            'isBooked': false,
            'bookedBy': null,
            'startTime': null,
            'endTime': null,
          });
        }
      }
    }
  }

  Future<void> bookMotoSlot(
    String slotId,
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final available = await isSlotAvailable(slotId, startTime, endTime);
    if (!available) {
      throw Exception('This slot is already booked for the selected time.');
    }
    await _db.collection('moto_slots').doc(slotId).update({
      'isBooked': true,
      'bookedBy': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    });
  }

  Future<void> cancelMotoSlot(String slotId, String userId) async {
    final docRef = _db.collection('moto_slots').doc(slotId);
    final snapshot = await docRef.get();
    if (snapshot.exists &&
        (snapshot['isBooked'] ?? false) &&
        snapshot['bookedBy'] == userId) {
      await docRef.update({
        'isBooked': false,
        'bookedBy': null,
        'startTime': null,
        'endTime': null,
      });
    } else {
      throw Exception('You can only cancel your own booking.');
    }
  }

  // ADMIN / EXTRA UTILITIES
  Future<List<DocumentSnapshot>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs;
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
