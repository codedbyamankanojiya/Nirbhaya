import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/contacts/domain/contact_model.dart';
import 'package:nirbhaya/features/contacts/data/contacts_api.dart';
import 'package:nirbhaya/features/contacts/data/contacts_repository.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';

final contactsApiProvider = Provider<ContactsApi>((ref) {
  return ContactsApi(ref.watch(apiClientProvider));
});

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsRepository(ref.watch(contactsApiProvider));
});

final contactsProvider = StateNotifierProvider<ContactsNotifier, AsyncValue<List<EmergencyContact>>>((ref) {
  return ContactsNotifier(ref.watch(contactsRepositoryProvider));
});

class ContactsNotifier extends StateNotifier<AsyncValue<List<EmergencyContact>>> {
  final ContactsRepository _repository;

  ContactsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    state = const AsyncValue.loading();
    try {
      final contacts = await _repository.getContacts();
      state = AsyncValue.data(contacts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String? email,
    int priority = 0,
    bool isPrimary = false,
    String? relation,
  }) async {
    try {
      final newContact = EmergencyContact(
        id: '', // Server will assign ID
        name: name,
        phone: phone,
        email: email,
        priority: priority,
        isPrimary: isPrimary,
        relation: relation,
      );
      await _repository.addContact(newContact);
      await loadContacts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateContact(
    String id, {
    required String name,
    required String phone,
    String? email,
    int priority = 0,
    bool isPrimary = false,
    String? relation,
  }) async {
    try {
      final updatedContact = EmergencyContact(
        id: id,
        name: name,
        phone: phone,
        email: email,
        priority: priority,
        isPrimary: isPrimary,
        relation: relation,
      );
      await _repository.updateContact(updatedContact);
      await loadContacts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _repository.deleteContact(id);
      await loadContacts();
    } catch (e) {
      rethrow;
    }
  }
}
