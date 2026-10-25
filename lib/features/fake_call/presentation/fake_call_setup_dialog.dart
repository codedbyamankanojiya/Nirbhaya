import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/features/fake_call/providers/fake_call_provider.dart';

class FakeCallSetupDialog extends ConsumerStatefulWidget {
  const FakeCallSetupDialog({super.key});

  @override
  ConsumerState<FakeCallSetupDialog> createState() => _FakeCallSetupDialogState();
}

class _FakeCallSetupDialogState extends ConsumerState<FakeCallSetupDialog> {
  final _nameController = TextEditingController(text: 'Mom');
  String _selectedRelation = 'Family';
  int _selectedDelay = 5;

  final List<String> _relations = ['Family', 'Friend', 'Work', 'Other'];
  final Map<int, String> _delays = {
    0: 'Now',
    5: '5s',
    15: '15s',
    30: '30s',
    60: '1m',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startFakeCall() {
    final notifier = ref.read(fakeCallProvider.notifier);
    notifier.setCallerInfo(_nameController.text.trim(), _selectedRelation);
    notifier.startFakeCall(_selectedDelay);
    
    context.pop();
    
    // Check if immediate start or delayed
    if (_selectedDelay == 0) {
      context.push('/fake-call');
    } else {
      context.showSnackBar('Fake call scheduled in $_selectedDelay seconds');
      // Background timer will navigate when ready if needed, or we just navigate right away and it waits?
      // Actually, if we navigate right away, it will be a blank screen waiting to ring?
      // Based on request: 'Start Fake Call' button that calls fakeCallProvider.startFakeCall() and navigates to FakeCallScreen
      context.push('/fake-call');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Setup Fake Call',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Caller Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _selectedRelation,
            decoration: const InputDecoration(
              labelText: 'Relation',
              prefixIcon: Icon(Icons.people_outline),
            ),
            items: _relations.map((relation) {
              return DropdownMenuItem(
                value: relation,
                child: Text(relation),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRelation = value;
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Delay',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _delays.entries.map((entry) {
              final isSelected = _selectedDelay == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDelay = entry.key;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _startFakeCall,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            ),
            child: const Text('Start Fake Call'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
