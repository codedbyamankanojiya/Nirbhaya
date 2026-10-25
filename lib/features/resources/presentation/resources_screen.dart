import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nirbhaya/app/theme.dart';
import 'package:nirbhaya/shared/extensions/context_extensions.dart';
import 'package:nirbhaya/shared/widgets/app_header.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _helplineFilter = 'all';
  final Set<String> _checkedChecklistItems = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) context.showSnackBar('Cannot dial $phoneNumber from this device.');
    }
  }

  Future<void> _sendSms(String phoneNumber, String message) async {
    final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09080F),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Crisis & Safety Center'),

            // Decoupled Segmented Navigation Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF161522),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.phone_in_talk, size: 18), text: 'Emergency Directory'),
                  Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Safety Guides & Rights'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmergencyDirectoryTab(),
                  _buildSafetyGuidesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: EMERGENCY DIRECTORY (1-Tap Direct Call & SMS)
  // -------------------------------------------------------------
  Widget _buildEmergencyDirectoryTab() {
    final helplines = [
      _Helpline(
        name: 'National Emergency Response (ERSS)',
        number: '112',
        subtitle: 'All-in-one single emergency number (Police, Fire, Ambulance)',
        category: 'police',
        icon: Icons.emergency,
        badge: '24/7 Toll-Free',
        color: const Color(0xFFE11D48),
      ),
      _Helpline(
        name: 'Women Helpline (All India)',
        number: '1091',
        subtitle: 'National level crisis dispatch & distress counseling',
        category: 'women',
        icon: Icons.support_agent,
        badge: 'National Women Care',
        color: const Color(0xFF9333EA),
      ),
      _Helpline(
        name: 'Women in Domestic Distress',
        number: '181',
        subtitle: 'One-stop center support & protection against domestic violence',
        category: 'women',
        icon: Icons.shield,
        badge: 'Govt Supported',
        color: const Color(0xFFC026D3),
      ),
      _Helpline(
        name: 'National Cyber Crime Reporting',
        number: '1930',
        subtitle: 'Report online stalking, harassment, non-consensual imagery & fraud',
        category: 'cyber',
        icon: Icons.security,
        badge: 'Govt Portal: cybercrime.gov.in',
        color: const Color(0xFF2563EB),
        webUrl: 'https://cybercrime.gov.in',
      ),
      _Helpline(
        name: 'Police Emergency Beat',
        number: '100',
        subtitle: 'Immediate local police patrol and PCR vehicle dispatch',
        category: 'police',
        icon: Icons.local_police,
        badge: 'Local Police',
        color: const Color(0xFF3B82F6),
      ),
      _Helpline(
        name: 'National Childline',
        number: '1098',
        subtitle: '24-hour emergency care for minors in distress',
        category: 'child',
        icon: Icons.child_care,
        badge: 'Minor Assistance',
        color: const Color(0xFF059669),
      ),
      _Helpline(
        name: 'Emergency Medical & Trauma Ambulance',
        number: '102',
        subtitle: 'Direct hospital ambulance & maternal emergency transfer',
        category: 'medical',
        icon: Icons.local_hospital,
        badge: 'Medical Care',
        color: const Color(0xFFDC2626),
      ),
      _Helpline(
        name: 'National Commission for Women (NCW)',
        number: '7827170170',
        subtitle: 'Dedicated helpline for women facing violence or dowry harassment',
        category: 'women',
        icon: Icons.gavel,
        badge: 'Statutory Body',
        color: const Color(0xFF7C3AED),
      ),
    ];

    final filtered = _helplineFilter == 'all'
        ? helplines
        : helplines.where((h) => h.category == _helplineFilter).toList();

    return Column(
      children: [
        // Category Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip('All Helplines', 'all'),
              _buildFilterChip('Police & ERSS', 'police'),
              _buildFilterChip('Women Crisis', 'women'),
              _buildFilterChip('Cyber Crime', 'cyber'),
              _buildFilterChip('Medical', 'medical'),
              _buildFilterChip('Child Safety', 'child'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14131E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item.icon, color: item.color, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.badge,
                                    style: TextStyle(color: item.color, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.subtitle,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _makePhoneCall(item.number),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: item.color,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.phone, size: 16),
                              label: Text('Call ${item.number}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _sendSms(item.number, 'Emergency! I need immediate assistance at my current location.'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.sms_outlined, size: 16),
                            label: const Text('SMS', style: TextStyle(fontSize: 12)),
                          ),
                          if (item.webUrl != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _openWebUrl(item.webUrl!),
                              icon: const Icon(Icons.open_in_new, color: Colors.cyanAccent, size: 20),
                              tooltip: 'Open Official Portal',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String category) {
    final isSelected = _helplineFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        selectedColor: const Color(0xFFE11D48),
        backgroundColor: const Color(0xFF14131E),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.white12),
        onSelected: (val) {
          setState(() => _helplineFilter = category);
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: SAFETY GUIDES, LEGAL RIGHTS & INTERACTIVE CHECKLISTS
  // -------------------------------------------------------------
  Widget _buildSafetyGuidesTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildGuideAccordion(
          title: '🥋 Physical Self-Defense & De-Escalation',
          category: 'Combat Readiness',
          color: const Color(0xFFE11D48),
          intro: 'Effective emergency physical defense relies on surprising attackers and creating a momentary window to escape.',
          checklist: [
            'Target High-Vulnerability Zones: Eyes, bridge of nose, throat trachea, groin, and kneecaps.',
            'The Heel-Palm Strike: Drive the heel of your open palm upward into the attacker\'s nose with body weight behind it.',
            'Escape from Wrist Grabs: Rotate your wrist sharply toward the attacker\'s thumb (their weakest grip point).',
            'Scream Specific Instructions: Yell "FIRE!" or "CALL POLICE ON THIS MAN!" rather than generic screams to overcome bystander apathy.',
            'Maintain the Ready Stance: Hands open at chest height in non-aggressive posture to defend head while talking.',
          ],
        ),

        const SizedBox(height: 12),

        _buildGuideAccordion(
          title: '⚖️ Legal Rights & Zero FIR Doctrine',
          category: 'Constitutional Protections',
          color: const Color(0xFF9333EA),
          intro: 'Under Indian Law, a woman possesses unassailable procedural rights at any police station across the nation.',
          checklist: [
            'Zero FIR Mandate: Any police station MUST register an FIR regardless of jurisdictional boundaries. Transfer occurs post-registration.',
            'Section 166A IPC: Any police officer refusing to register an FIR in cases of crimes against women faces criminal prosecution.',
            'No Night-Time Arrest: Women cannot be arrested after sunset and before sunrise without prior magistrate permission.',
            'Examination at Residence: Women and minors cannot be summoned to police stations; statements must be recorded at their home.',
            'Free Legal Aid: Under Legal Services Authorities Act, all women are entitled to free legal aid lawyers in court.',
          ],
        ),

        const SizedBox(height: 12),

        _buildGuideAccordion(
          title: '🚕 Travel, Cab & Transit Safety Protocol',
          category: 'Transit Checklist',
          color: const Color(0xFFF59E0B),
          intro: 'Crucial verification steps when traveling alone via cabs, auto-rickshaws, or unfamiliar routes at night.',
          checklist: [
            'Match Number Plate & Driver: Never enter a cab before checking vehicle registration matches the app.',
            'Child-Lock Verification: Open and test rear door handles from the inside to verify child-locks are disengaged.',
            'Simulate Phone Call: Loudly state: "I have shared my live ride location and vehicle number with my family."',
            'Monitor Route Drift: Keep your phone GPS map open. If the driver deviates into dark detours, demand immediate stop in public space.',
            'Pre-Program Speed Dial 112: Keep phone volume on and fingers positioned for emergency button trigger.',
          ],
        ),

        const SizedBox(height: 12),

        _buildGuideAccordion(
          title: '📱 Digital Safety & Anti-Stalking Protocol',
          category: 'Cyber Protection',
          color: const Color(0xFF2563EB),
          intro: 'Protect your digital footprint against location-sharing spyware, cyber stalking, and unauthorized device tracking.',
          checklist: [
            'Audit Background Permissions: Go to Android Settings > Apps > Special App Access and revoke unnecessary Location/Mic access.',
            'Review Google Location Sharing: Check Google Maps > Location Sharing for any unauthorized secondary emails receiving your location.',
            'Enable 2FA Everywhere: Use authenticator apps rather than SMS for email, banking, and WhatsApp verification.',
            'Preserve Cyber Evidence: Take uncropped screenshots including timestamps and URLs before reporting to 1930.',
            'Emergency Camera/Mic Blocker: Toggle quick-settings tiles to disable camera and microphone system-wide.',
          ],
        ),

        const SizedBox(height: 12),

        _buildGuideAccordion(
          title: '🏠 Domestic Protection Shield (PWDVA 2005)',
          category: 'Domestic Rights',
          color: const Color(0xFF059669),
          intro: 'Protection of Women from Domestic Violence Act provides rapid emergency injunctions and shelter protections.',
          checklist: [
            'Right to Reside: You cannot be evicted from shared matrimonial household regardless of whether you have ownership title.',
            'Protection Orders: Magistrates can issue restraining orders prohibiting the abuser from entering your workplace or residence.',
            'Free Shelter & Medical Facility: One-Stop Centers (181) provide immediate safe shelter, medical aid, and counseling.',
            'Document Medical Evidence: Get a government hospital MLC (Medico-Legal Certificate) immediately after any physical injury.',
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGuideAccordion({
    required String title,
    required String category,
    required Color color,
    required String intro,
    required List<String> checklist,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14131E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: color,
          collapsedIconColor: Colors.white60,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(intro, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 12),
                  const Text('ACTION CHECKLIST:', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  ...checklist.map((item) {
                    final isChecked = _checkedChecklistItems.contains(item);
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: isChecked,
                      activeColor: color,
                      checkColor: Colors.white,
                      title: Text(
                        item,
                        style: TextStyle(
                          color: isChecked ? Colors.white38 : Colors.white,
                          fontSize: 12.5,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _checkedChecklistItems.add(item);
                          } else {
                            _checkedChecklistItems.remove(item);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Helpline {
  final String name;
  final String number;
  final String subtitle;
  final String category;
  final IconData icon;
  final String badge;
  final Color color;
  final String? webUrl;

  const _Helpline({
    required this.name,
    required this.number,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.badge,
    required this.color,
    this.webUrl,
  });
}
