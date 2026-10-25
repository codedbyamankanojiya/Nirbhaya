import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/auth/domain/user_model.dart';
import 'package:nirbhaya/features/profile/providers/profile_provider.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';

class EditMedicalDialog extends ConsumerStatefulWidget {
  final ProfileModel? profile;

  const EditMedicalDialog({super.key, this.profile});

  @override
  ConsumerState<EditMedicalDialog> createState() => _EditMedicalDialogState();
}

class _EditMedicalDialogState extends ConsumerState<EditMedicalDialog> {
  String? _selectedBloodGroup;
  late final TextEditingController _allergiesController;
  late final TextEditingController _conditionsController;
  late final TextEditingController _physicianController;
  late final TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBloodGroup = widget.profile?.bloodGroup;
    _allergiesController = TextEditingController(text: widget.profile?.allergies ?? '');
    _conditionsController = TextEditingController(text: widget.profile?.conditions ?? '');
    _physicianController = TextEditingController(text: widget.profile?.primaryPhysician ?? '');
    _notesController = TextEditingController(text: widget.profile?.medicalNotes ?? '');
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _physicianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(profileProvider.notifier).updateMedicalInfo(
            bloodGroup: _selectedBloodGroup,
            allergies: _allergiesController.text.trim().isNotEmpty ? _allergiesController.text.trim() : null,
            conditions: _conditionsController.text.trim().isNotEmpty ? _conditionsController.text.trim() : null,
            primaryPhysician: _physicianController.text.trim().isNotEmpty ? _physicianController.text.trim() : null,
            notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
          );
      if (mounted) {
        context.showSnackBar('Medical emergency card updated successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to update medical info: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
              'Medical Emergency Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'First responders will reference these critical stats during an emergency.',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              dropdownColor: const Color(0xFF1E1E2C),
              style: const TextStyle(color: Colors.white),
              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBloodGroup = v),
              decoration: const InputDecoration(labelText: 'Blood Group'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _allergiesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Allergies (e.g. Penicillin, Peanuts)',
                prefixIcon: Icon(Icons.warning_amber_rounded, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _conditionsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Pre-existing Medical Conditions (e.g. Asthma, Diabetes)',
                prefixIcon: Icon(Icons.favorite_border, color: Colors.redAccent),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _physicianController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Primary Physician & Hospital Contact',
                prefixIcon: Icon(Icons.local_hospital_outlined, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Special Emergency Treatment Notes',
                prefixIcon: Icon(Icons.medical_information_outlined, color: Colors.tealAccent),
              ),
              maxLines: 2,
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
                      : const Text('Save Medical Card'),
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
