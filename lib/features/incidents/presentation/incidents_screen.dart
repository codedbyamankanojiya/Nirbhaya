import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nirbhaya/features/incidents/providers/incidents_provider.dart';
import 'package:nirbhaya/features/incidents/presentation/create_incident_dialog.dart';
import 'package:nirbhaya/shared/widgets/empty_state.dart';
import 'package:nirbhaya/shared/widgets/status_badge.dart';
import 'package:nirbhaya/core/utils/date_formatter.dart';

class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  void _showCreateIncidentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateIncidentDialog(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'INVESTIGATING':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(incidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident History'),
      ),
      body: incidentsAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const EmptyState(
              icon: Icons.shield_outlined,
              title: 'No incidents reported',
              description: 'You have not reported any incidents yet.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(incidentsProvider.notifier).loadIncidents(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                incident.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(
                              text: incident.status,
                              color: _getStatusColor(incident.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          incident.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                incident.category,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            Text(
                              formatDateTime(incident.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(incidentsProvider.notifier).loadIncidents(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateIncidentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
