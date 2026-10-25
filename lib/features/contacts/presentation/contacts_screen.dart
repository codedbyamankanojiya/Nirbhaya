import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/contacts_provider.dart';
import '../domain/contact_model.dart';
import 'add_contact_dialog.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../app/theme.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddContactDialog(BuildContext context, {EmergencyContact? contact}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddContactDialog(contact: contact),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text(
              'Are you sure you want to remove this emergency contact from your safety dispatch list?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactDialog(context),
        backgroundColor: const Color(0xFFE11D48),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Guardian', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Emergency Contacts', showBack: true),

            // Search Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search contacts by name or phone...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white60),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            Expanded(
              child: contactsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => ref.read(contactsProvider.notifier).loadContacts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (contacts) {
                  // Sort: Primary first, then by name
                  final sorted = List<EmergencyContact>.from(contacts)
                    ..sort((a, b) {
                      if (a.isPrimary && !b.isPrimary) return -1;
                      if (!a.isPrimary && b.isPrimary) return 1;
                      return a.name.compareTo(b.name);
                    });

                  final filtered = sorted.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        c.phone.toLowerCase().contains(_searchQuery) ||
                        (c.relation?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off : Icons.contact_phone_outlined,
                            size: 64,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No contacts match "$_searchQuery"'
                                : 'No emergency contacts registered yet',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Add at least 2 trusted guardians for instant SOS dispatch.',
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_searchQuery.isEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _showAddContactDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Primary Guardian'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48),
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(contactsProvider.notifier).loadContacts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        top: AppSpacing.sm,
                        bottom: 90,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final contact = filtered[index];
                        return Dismissible(
                          key: Key(contact.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(context),
                          onDismissed: (_) {
                            ref.read(contactsProvider.notifier).deleteContact(contact.id);
                            context.showSnackBar('Contact deleted');
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSpacing.lg),
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: contact.isPrimary
                                    ? const Color(0xFFE11D48).withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.08),
                                width: contact.isPrimary ? 1.5 : 1,
                              ),
                            ),
                            color: const Color(0xFF14131E),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showAddContactDialog(context, contact: contact),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: contact.isPrimary
                                          ? const Color(0xFFE11D48)
                                          : const Color(0xFF2A283E),
                                      child: Text(
                                        contact.name.isNotEmpty
                                            ? contact.name.substring(0, 1).toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),

                                    // Contact details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  contact.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (contact.isPrimary) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFE11D48), width: 0.8),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.star, color: Color(0xFFFDA4AF), size: 10),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        'PRIMARY',
                                                        style: TextStyle(
                                                          color: Color(0xFFFDA4AF),
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            contact.phone,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  contact.relation ?? 'Emergency Contact',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.cloud_done_outlined, size: 12, color: Colors.greenAccent),
                                              const SizedBox(width: 3),
                                              const Text('Synced', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quick Cellular Actions
                                    IconButton(
                                      icon: const Icon(Icons.message_outlined, color: Colors.amberAccent, size: 22),
                                      tooltip: 'Send SMS',
                                      onPressed: () => _sendSms(contact.phone),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.greenAccent, size: 22),
                                      tooltip: 'Direct Call',
                                      onPressed: () => _makePhoneCall(contact.phone),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
