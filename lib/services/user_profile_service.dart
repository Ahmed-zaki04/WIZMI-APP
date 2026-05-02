import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  static Future<Map<String, String>> getQuickFillData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return {};
      final data = doc.data()!;
      return {
        'name': data['name'] ?? data['firstName'] ?? '',
        'phone': data['phone'] ?? '',
        'carModel': data['carModel'] ?? '',
        'carBrand': data['carBrand'] ?? '',
        'plateNumber': data['plateNumber'] ?? '',
        'address': data['address'] ?? '',
      };
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCarProfile({
    required String carBrand,
    required String carModel,
    required String plateNumber,
    String carYear = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'carBrand': carBrand,
      'carModel': carModel,
      'plateNumber': plateNumber,
      if (carYear.isNotEmpty) 'carYear': carYear,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
