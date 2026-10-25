import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nirbhaya/features/auth/providers/auth_providers.dart';
import 'package:nirbhaya/features/contacts/providers/contacts_provider.dart';
import 'package:nirbhaya/features/profile/presentation/edit_medical_dialog.dart';
import 'package:nirbhaya/features/profile/presentation/edit_profile_dialog.dart';
import 'package:nirbhaya/features/profile/providers/profile_provider.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';
import 'package:nirbhaya/app/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  void _openEditProfileDialog(dynamic profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  void _openEditMedicalDialog(dynamic profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EditMedicalDialog(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final contactsState = ref.watch(contactsProvider);

    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      appBar: const AppHeader(title: 'My Safety Profile', showBack: true),
      body: profileState.when(
        data: (profileData) {
          final activeProfile = profileData ?? user?.profile;

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileProvider.notifier).loadProfile();
              await ref.read(contactsProvider.notifier).loadContacts();
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (!isAuthenticated)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.base),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Offline Device Storage: Your safety profile is encrypted locally on this device.',
                            style: TextStyle(color: Colors.amber, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // User Identity Banner Card
                Card(
                  elevation: 0,
                  color: const Color(0xFF161522),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFF59E0B)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF1E1E2C),
                            child: Text(
                              (activeProfile?.name.isNotEmpty == true)
                                  ? activeProfile!.name[0].toUpperCase()
                                  : 'N',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeProfile?.name.isNotEmpty == true ? activeProfile!.name : 'Registered Protector',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'Encrypted Local Device Account',
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAuthenticated ? Colors.green.withValues(alpha: 0.2) : Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isAuthenticated ? 'Cloud Synced' : 'Device Protected',
                                      style: TextStyle(
                                        color: isAuthenticated ? Colors.greenAccent : Colors.amberAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isAuthenticated)
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent),
                            tooltip: 'Logout',
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              context.go('/login');
                            },
                          )
                        else
                          ElevatedButton(
                            onPressed: () => context.push('/login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Login'),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Personal Details Card
                _buildCard(
                  title: 'Personal Details',
                  icon: Icons.person_outline,
                  onEdit: () => _openEditProfileDialog(activeProfile),
                  children: [
                    _buildInfoRow('Full Legal Name', activeProfile?.name.isNotEmpty == true ? activeProfile!.name : 'Not configured'),
                    _buildInfoRow('Emergency Phone', activeProfile?.emergencyPhone ?? 'Not configured'),
                    _buildInfoRow('Emergency Email', activeProfile?.emergencyEmail ?? 'Not configured'),
                    _buildInfoRow('Home / Safe Address', activeProfile?.address ?? 'Not configured'),
                    _buildInfoRow('Date of Birth', activeProfile?.dob ?? 'Not configured'),
                    _buildInfoRow('Gender', activeProfile?.gender ?? 'Not configured'),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Medical Information Card
                _buildCard(
                  title: 'Medical Emergency Card',
                  icon: Icons.medical_services_outlined,
                  accentColor: Colors.redAccent,
                  onEdit: () => _openEditMedicalDialog(activeProfile),
                  children: [
                    _buildInfoRow('Blood Group', activeProfile?.bloodGroup ?? 'Not set', isBadge: true),
                    _buildInfoRow('Allergies', activeProfile?.allergies ?? 'None recorded'),
                    _buildInfoRow('Pre-existing Conditions', activeProfile?.conditions ?? 'None recorded'),
                    _buildInfoRow('Primary Physician', activeProfile?.primaryPhysician ?? 'Not recorded'),
                    _buildInfoRow('Emergency Care Notes', activeProfile?.medicalNotes ?? 'None recorded'),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Emergency Identifiers Card
                _buildCard(
                  title: 'Emergency Identifiers',
                  icon: Icons.shield_outlined,
                  accentColor: Colors.amberAccent,
                  onEdit: () => _openEditProfileDialog(activeProfile),
                  children: [
                    _buildInfoRow('Govt ID / Document No.', activeProfile?.govtId ?? 'Not configured'),
                    _buildInfoRow('Emergency Safe-Word / Code', activeProfile?.emergencyCode != null ? '••••••••' : 'Not configured'),
                    _buildInfoRow('Vehicle Registration No.', activeProfile?.vehicleNumber ?? 'Not configured'),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Trusted Emergency Guardians Card
                _buildCard(
                  title: 'Registered Guardians',
                  icon: Icons.people_outline,
                  accentColor: Colors.greenAccent,
                  onEdit: () => context.push('/contacts'),
                  editText: 'Manage',
                  children: [
                    contactsState.when(
                      data: (contacts) {
                        if (contacts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'No trusted contacts registered. Tap Manage to add guardians.',
                              style: TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          );
                        }
                        return Column(
                          children: contacts.take(3).map((c) {
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: c.isPrimary ? const Color(0xFFE11D48) : Colors.white24,
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0] : '?',
                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  if (c.isPrimary) ...[
                                    const SizedBox(width: 6),
                                    const Text('★ Primary', style: TextStyle(color: Color(0xFFFDA4AF), fontSize: 10)),
                                  ],
                                ],
                              ),
                              subtitle: Text(c.phone, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(c.relation ?? 'Contact', style: const TextStyle(color: Colors.white60, fontSize: 10)),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading profile: $err', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    Color accentColor = const Color(0xFFFDA4AF),
    VoidCallback? onEdit,
    String editText = 'Edit',
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFF161522),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                if (onEdit != null)
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFDA4AF),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(editText),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: isBadge
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
          ),
        ],
      ),
    );
  }
}
