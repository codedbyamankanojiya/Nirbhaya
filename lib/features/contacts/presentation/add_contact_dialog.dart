import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/contact_model.dart';
import '../providers/contacts_provider.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../app/theme.dart';

class AddContactDialog extends ConsumerStatefulWidget {
  final EmergencyContact? contact;

  const AddContactDialog({super.key, this.contact});

  @override
  ConsumerState<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends ConsumerState<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late String _relation;
  late bool _isPrimary;
  late int _priority;
  bool _isLoading = false;

  final List<String> _relations = [
    'Parent',
    'Spouse',
    'Sibling',
    'Guardian',
    'Friend',
    'Family',
    'Doctor',
    'Police',
    'Neighbor',
    'Colleague',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.contact?.name ?? '';
    _phoneController.text = widget.contact?.phone ?? '';
    _emailController.text = widget.contact?.email ?? '';
    _relation = widget.contact?.relation ?? 'Family';
    if (!_relations.contains(_relation)) {
      _relation = 'Other';
    }
    _isPrimary = widget.contact?.isPrimary ?? false;
    _priority = widget.contact?.priority ?? (_isPrimary ? 1 : 2);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickFromPhonebook() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      if (mounted) {
        _showPresetOrNativePickerModal();
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        context.showSnackBar('Please enable contacts permission in Settings to import from phonebook.');
      }
    } else {
      if (mounted) {
        context.showSnackBar('Contacts permission denied.');
      }
    }
  }

  void _showPresetOrNativePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Safety Presets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Select an emergency authority or quick template:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE11D48),
                child: Icon(Icons.local_police, color: Colors.white),
              ),
              title: const Text('National Emergency (ERSS)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('112 - Police, Fire & Medical', style: TextStyle(color: Colors.white60)),
              onTap: () {
                _nameController.text = 'National Emergency ERSS';
                _phoneController.text = '112';
                setState(() => _relation = 'Police');
                Navigator.pop(ctx);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF7C3AED),
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              title: const Text('Women Helpline (All India)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('1091 - 24/7 Safety Dispatch', style: TextStyle(color: Colors.white60)),
              onTap: () {
                _nameController.text = 'Women Helpline';
                _phoneController.text = '1091';
                setState(() => _relation = 'Guardian');
                Navigator.pop(ctx);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF059669),
                child: Icon(Icons.local_hospital, color: Colors.white),
              ),
              title: const Text('National Ambulance Service', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('102 / 108 - Trauma Care', style: TextStyle(color: Colors.white60)),
              onTap: () {
                _nameController.text = 'Emergency Ambulance';
                _phoneController.text = '102';
                setState(() => _relation = 'Doctor');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(contactsProvider.notifier);
      final emailValue = _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null;

      if (widget.contact == null) {
        await notifier.addContact(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: emailValue,
          relation: _relation,
          isPrimary: _isPrimary,
          priority: _priority,
        );
        if (mounted) context.showSnackBar('Emergency contact saved and synced.');
      } else {
        await notifier.updateContact(
          widget.contact!.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: emailValue,
          relation: _relation,
          isPrimary: _isPrimary,
          priority: _priority,
        );
        if (mounted) context.showSnackBar('Emergency contact updated successfully.');
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) context.showSnackBar('Failed to save contact: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.contact == null ? 'Add Emergency Contact' : 'Edit Contact',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickFromPhonebook,
                    icon: const Icon(Icons.contact_phone, size: 16),
                    label: const Text('Phonebook', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFDA4AF),
                      side: const BorderSide(color: Color(0xFFFDA4AF)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),

              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number (with Country Code)',
                  prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone number is required';
                  if (v.trim().length < 3) return 'Please enter a valid phone number';
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address (Optional)',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Relationship Selector
              DropdownButtonFormField<String>(
                value: _relation,
                dropdownColor: const Color(0xFF1E1E2C),
                style: const TextStyle(color: Colors.white),
                items: _relations
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _relation = v ?? 'Other'),
                decoration: InputDecoration(
                  labelText: 'Relationship Tag',
                  prefixIcon: const Icon(Icons.people_outline, color: Colors.white70),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Priority / Primary Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: SwitchListTile(
                  title: const Text('Designate as Primary Guardian', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                    'Directly alerted first with live GPS coordinates upon SOS trigger',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  value: _isPrimary,
                  activeColor: const Color(0xFFE11D48),
                  onChanged: (val) {
                    setState(() {
                      _isPrimary = val;
                      _priority = val ? 1 : 2;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.contact == null ? 'Save Emergency Contact' : 'Update Emergency Contact',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
