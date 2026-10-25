import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/features/profile/providers/profile_provider.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final ProfileModel? profile;

  const EditProfileDialog({super.key, this.profile});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _govtIdController;
  late final TextEditingController _emergencyCodeController;
  late final TextEditingController _vehicleNumberController;

  String? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _phoneController = TextEditingController(text: widget.profile?.emergencyPhone ?? '');
    _emailController = TextEditingController(text: widget.profile?.emergencyEmail ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
    _govtIdController = TextEditingController(text: widget.profile?.govtId ?? '');
    _emergencyCodeController = TextEditingController(text: widget.profile?.emergencyCode ?? '');
    _vehicleNumberController = TextEditingController(text: widget.profile?.vehicleNumber ?? '');
    _selectedDate = widget.profile?.dob;
    _selectedGender = widget.profile?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _govtIdController.dispose();
    _emergencyCodeController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(profileProvider.notifier);
      await notifier.updatePersonalInfo(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        dob: _selectedDate,
        gender: _selectedGender,
      );
      await notifier.updateEmergencyIdentifiers(
        govtId: _govtIdController.text.trim().isNotEmpty ? _govtIdController.text.trim() : null,
        emergencyCode: _emergencyCodeController.text.trim().isNotEmpty ? _emergencyCodeController.text.trim() : null,
        vehicleNumber: _vehicleNumberController.text.trim().isNotEmpty ? _vehicleNumberController.text.trim() : null,
      );

      if (mounted) {
        context.showSnackBar('Personal safety profile updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to update profile: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Personal Details & Identifiers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Emergency responders and authorities rely on these details for identity verification.',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Legal Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Primary Emergency Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Emergency Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Home / Base Address',
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date of Birth'),
                      child: Text(_selectedDate ?? 'Select DOB', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    dropdownColor: const Color(0xFF1E1E2C),
                    style: const TextStyle(color: Colors.white),
                    items: ['Female', 'Male', 'Non-binary', 'Prefer not to say']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(color: Colors.white12),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Emergency Identifiers',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFDA4AF)),
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _govtIdController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Govt ID / Aadhaar / Passport No.',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _emergencyCodeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Emergency Duress Code / Safe-Word',
                prefixIcon: Icon(Icons.lock_person_outlined),
              ),
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _vehicleNumberController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Vehicle Registration No.',
                prefixIcon: Icon(Icons.directions_car_outlined),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
