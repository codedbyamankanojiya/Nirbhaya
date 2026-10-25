import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhaya/core/services/firebase_sync_service.dart';
import '../domain/contact_model.dart';
import 'contacts_api.dart';

class ContactsRepository {
  final ContactsApi _api;
  final FirebaseSyncService _firebaseSyncService = FirebaseSyncService();
  static const String _cacheKey = 'cached_contacts';

  ContactsRepository(this._api);

  Future<List<EmergencyContact>> getContacts() async {
    try {
      final response = await _api.getContacts();
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        final contacts = data.map((e) => EmergencyContact.fromJson(e)).toList();
        await _cacheContacts(contacts);
        return contacts;
      }
      return await _getCachedContacts();
    } catch (_) {
      return await _getCachedContacts();
    }
  }

  Future<EmergencyContact> addContact(EmergencyContact contact) async {
    try {
      final response = await _api.addContact(
        name: contact.name,
        phone: contact.phone,
        email: contact.email,
        isPrimary: contact.isPrimary,
        priority: contact.priority,
        relation: contact.relation,
      );
      if (response.success && response.data != null) {
        final serverContact = EmergencyContact.fromJson(response.data);
        final list = await _getCachedContacts();
        list.add(serverContact);
        await _cacheContacts(list);
        return serverContact;
      }
    } catch (_) {
      // Local fallback for guest / offline mode
    }

    final localContact = contact.copyWith(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
    );
    final cached = await _getCachedContacts();
    cached.add(localContact);
    await _cacheContacts(cached);
    return localContact;
  }

  Future<EmergencyContact> updateContact(EmergencyContact contact) async {
    if (!contact.id.startsWith('local_')) {
      try {
        final response = await _api.updateContact(contact.id, contact.toJson());
        if (response.success && response.data != null) {
          final updated = EmergencyContact.fromJson(response.data);
          final list = await _getCachedContacts();
          final index = list.indexWhere((c) => c.id == contact.id);
          if (index != -1) {
            list[index] = updated;
            await _cacheContacts(list);
          }
          return updated;
        }
      } catch (_) {
        // Fallback to updating local cache
      }
    }

    final list = await _getCachedContacts();
    final index = list.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      list[index] = contact;
      await _cacheContacts(list);
    }
    return contact;
  }

  Future<void> deleteContact(String id) async {
    if (!id.startsWith('local_')) {
      try {
        await _api.deleteContact(id);
      } catch (_) {
        // Continue to remove locally
      }
    }

    final list = await _getCachedContacts();
    list.removeWhere((c) => c.id == id);
    await _cacheContacts(list);
  }

  Future<void> _cacheContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
    // Background cloud sync to Cloud Firestore
    _firebaseSyncService.syncEmergencyContacts(contacts);
  }

  Future<List<EmergencyContact>> _getCachedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((e) => EmergencyContact.fromJson(e)).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}
