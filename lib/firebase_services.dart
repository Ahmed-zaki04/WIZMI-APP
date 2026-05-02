import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseServices {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> setHomepageBanner(String imageUrl) async {
    try {
      await _firestore.collection('homepage').doc('banner').set({
        'image': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Banner image URL updated successfully');
    } catch (e) {
      debugPrint('Error updating banner image: $e');
      throw e;
    }
  }

  static Future<String?> getHomepageBanner() async {
    try {
      final doc = await _firestore.collection('homepage').doc('banner').get();
      if (doc.exists) {
        return doc.data()?['image'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching banner image: $e');
      return null;
    }
  }
} 