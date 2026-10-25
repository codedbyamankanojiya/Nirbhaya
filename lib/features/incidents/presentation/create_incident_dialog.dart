import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/location/providers/location_provider.dart';
import 'package:nirbhaya/features/incidents/providers/incidents_provider.dart';
import 'package:nirbhaya/core/utils/validators.dart';

class CreateIncidentDialog extends ConsumerStatefulWidget {
  const CreateIncidentDialog({super.key});

  @override
  ConsumerState<CreateIncidentDialog> createState() => _CreateIncidentDialogState();
}

class _CreateIncidentDialogState extends ConsumerState<CreateIncidentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  bool _isAnonymous = false;
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Harassment',
    'Stalking',
    'Assault',
    'Theft',
    'Suspicious Activity',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final locationService = ref.read(locationServiceProvider);
        final position = await locationService.getCurrentPosition();
        await ref.read(incidentsProvider.notifier).createIncident(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          latitude: position?.latitude,
          longitude: position?.longitude,
          isAnonymous: _isAnonymous,
        );
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incident reported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Report Incident',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  validator: validateRequired,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                  ),
                  dropdownColor: const Color(0xFF1E1E2C),
                  style: const TextStyle(color: Colors.white),
                  initialValue: _selectedCategory,
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  },
                  validator: (val) => val == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Report Anonymously', style: TextStyle(color: Colors.white)),
                  value: _isAnonymous,
                  activeThumbColor: const Color(0xFF9D84F5),
                  onChanged: (val) {
                    setState(() {
                      _isAnonymous = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  label: const Text('Attach Evidence', style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D84F5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
