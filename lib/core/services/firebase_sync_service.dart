import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nirbhaya/features/contacts/domain/contact_model.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? 'guest_device_user';

  /// Dispatches an active SOS distress signal to Cloud Firestore
  Future<String?> recordSosAlert({
    required double? latitude,
    required double? longitude,
    required String description,
  }) async {
    try {
      final docRef = _firestore.collection('sos_alerts').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': _currentUserId,
        'status': 'ACTIVE',
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Firestore SOS dispatch fallback: $e');
      return null;
    }
  }

  /// Updates the status of an existing SOS incident (e.g. CANCELLED, RESOLVED, FALSE_ALARM)
  Future<void> updateSosStatus(String sosId, String status) async {
    try {
      if (sosId.isEmpty || sosId.startsWith('local_')) return;
      await _firestore.collection('sos_alerts').doc(sosId).update({
        'status': status,
        'resolvedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore update status fallback: $e');
    }
  }

  /// Syncs user emergency contacts to Cloud Firestore
  Future<void> syncEmergencyContacts(List<EmergencyContact> contacts) async {
    try {
      final batch = _firestore.batch();
      final contactsCollection = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('contacts');

      for (final contact in contacts) {
        final docRef = contactsCollection.doc(contact.id.toString());
        batch.set(docRef, {
          'id': contact.id,
          'name': contact.name,
          'phone': contact.phone,
          'email': contact.email,
          'relation': contact.relation,
          'priority': contact.priority,
          'isPrimary': contact.isPrimary,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore sync contacts fallback: $e');
    }
  }

  /// Syncs user profile and medical card details to Cloud Firestore
  Future<void> syncProfile(ProfileModel profile) async {
    try {
      await _firestore.collection('users').doc(_currentUserId).set({
        'id': profile.id,
        'name': profile.name,
        'email': profile.emergencyEmail,
        'phone': profile.emergencyPhone,
        'bloodGroup': profile.bloodGroup,
        'allergies': profile.allergies,
        'conditions': profile.conditions,
        'emergencyContact': profile.emergencyPhone,
        'vehicleNumber': profile.vehicleNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync profile fallback: $e');
    }
  }
}
