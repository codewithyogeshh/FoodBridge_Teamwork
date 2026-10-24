import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../../data/services/localization_service.dart';
import '../../../data/services/offline_sync_service.dart';

/// Clean Modern Light & Fresh Emerald Role Selection Screen
/// Inspired by top mobile design systems (UberEats, Airbnb, Linear)
/// Features crisp white cards, warm ivory canvas, vibrant emerald highlights,
/// dynamic selection halation, and ergonomic sticky action dock.
class RoleSelectionScreen extends StatefulWidget {
  final void Function(UserRole role) onRoleSelected;

  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole _selectedRole = UserRole.donor;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _roles = [
    {
      'role': UserRole.donor,
      'title': 'Commercial Food Donor',
      'subtitle': 'Restaurants, Caterers, Hotels & Food Manufacturers',
      'description':
          'Post surplus edible food in 60 seconds. Our AI perishability engine matches ultra-close shelters before food expires.',
      'icon': Icons.storefront_rounded,
      'tag': 'SURPLUS PROVIDER • TAX ACCREDITED',
      'tagColor': Color(0xFF059669),
      'tagBg': Color(0xFFECFDF5),
      'perks': [
        '⚡ 15m Dispatch',
        'Automated 80G Receipts',
        'Cold Chain Tracking',
      ],
    },
    {
      'role': UserRole.community,
      'title': 'Community Giver',
      'subtitle': 'Citizens, Families, Students & Philanthropists',
      'description':
          'Donate spare clothes, blankets, school books, or sponsor hot meals with instant 80G tax exemption receipts and full anonymous privacy mode.',
      'icon': Icons.volunteer_activism_rounded,
      'tag': 'HYPER-LOCAL NEIGHBORHOOD • ANYONE CAN GIVE',
      'tagColor': Color(0xFFD97706),
      'tagBg': Color(0xFFFEF3C7),
      'perks': [
        'Direct Drop-off',
        'Instant 80G Receipt',
        'Anonymous Mode',
      ],
    },
    {
      'role': UserRole.ngo,
      'title': 'Verified NGO / Shelter Kitchen',
      'subtitle': 'Shelter Homes, Food Banks & Rescue Fleets',
      'description':
          'Discover nearby surplus food and community gifts on real-time radar maps. Claim with atomic locks and secure OTP custody verification.',
      'icon': Icons.soup_kitchen_rounded,
      'tag': 'LICENSED RESCUER • PRIORITY ALLOCATION',
      'tagColor': Color(0xFF0D9488),
      'tagBg': Color(0xFFF0FDFA),
      'perks': [
        'Live Radar Map',
        'Atomic Claim Locks',
        'FSSAI Verified',
      ],
    },
    {
      'role': UserRole.admin,
      'title': 'Platform Admin & Compliance',
      'subtitle': 'Auditor, Operations & Safety Desk',
      'description':
          'Inspect uploaded Aadhaar/PAN and FSSAI food safety licenses, verify delivery logs, oversee real-time logistics, and export statutory audit trails.',
      'icon': Icons.radar_rounded,
      'tag': 'RESTRICTED SSO • OPERATIONS & GOVERNANCE',
      'tagColor': Color(0xFF4F46E5),
      'tagBg': Color(0xFFEEF2FF),
      'perks': [
        'Credential Vault',
        'Live Dispatch Log',
        'Statutory Reports',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService.instance;
    final offline = OfflineSyncService.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([loc, offline]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF9),
          body: Stack(
            children: [
              // SCROLLABLE ONBOARDING CONTENT
              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      children: [
                        // FIXED BRAND HEADER BAR
                        _buildTopHeader(context, loc, offline),

                        // MAIN SCROLLABLE CARDS AREA
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // STEP TRACKER & LIVE RESCUE TICKER
                                _buildIdentityTickerHeader(),
                                const SizedBox(height: 12),

                                // MAIN HEADLINE & SUBTITLE
                                Text(
                                  loc.tr('role_select_title'),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                    color: Color(0xFF111827),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loc.tr('role_select_desc'),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF4B5563),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // 4 PERSONA SELECTION CARDS
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _roles.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    final item = _roles[index];
                                    final UserRole role =
                                        item['role'] as UserRole;
                                    final bool isSelected =
                                        _selectedRole == role;
                                    final Color tagColor =
                                        item['tagColor'] as Color;
                                    final Color tagBg =
                                        item['tagBg'] as Color;
                                    final List<String> perks =
                                        item['perks'] as List<String>;

                                    return _buildPersonaCard(
                                      item: item,
                                      role: role,
                                      isSelected: isSelected,
                                      tagColor: tagColor,
                                      tagBg: tagBg,
                                      perks: perks,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),

                                // STATUTORY TRUST & PROTECTION SEAL
                                _buildGoodSamaritanTrustSeal(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ERGONOMIC FLOATING BOTTOM ACTION DOCK
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionDock(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Clean High-Trust Header
  Widget _buildTopHeader(
      BuildContext context, LocalizationService loc, OfflineSyncService offline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          // Botanical Brand Emblem
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),

          // Brand Title & Badge
          Row(
            children: [
              Text(
                loc.tr('app_title'),
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  '2.0',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Bank-Grade SSL Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.lock_rounded, size: 11, color: Color(0xFF059669)),
                const SizedBox(width: 4),
                const Text(
                  '256-Bit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Connectivity Pill
          InkWell(
            onTap: () {
              offline.toggleConnectivity();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(offline.isOnline
                      ? 'Online Mode! Real-time Supabase sync active.'
                      : 'Offline Field Mode! Data safely queued locally.'),
                  backgroundColor: offline.isOnline
                      ? const Color(0xFF059669)
                      : const Color(0xFFD97706),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: offline.isOnline
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: offline.isOnline
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    offline.isOnline
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    size: 11,
                    color: offline.isOnline
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offline.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: offline.isOnline
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Language Switcher
          InkWell(
            onTap: () => _showLanguageDialog(context, loc),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Text(loc.currentLanguage.flag,
                      style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    loc.currentLanguage.name.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 13, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Step Tracker & Live Rescue Metric Ticker
  Widget _buildIdentityTickerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Step Tracker
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'STEP 1 OF 3 • IDENTITY ARCHITECTURE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF059669),
              ),
            ),
          ],
        ),

        // Live Rescue Counter Ticker Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Icon(
                  Icons.autorenew_rounded,
                  size: 11,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '14.2k kg rescued today',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Individual Persona Card (Clean Modern Light)
  Widget _buildPersonaCard({
    required Map<String, dynamic> item,
    required UserRole role,
    required bool isSelected,
    required Color tagColor,
    required Color tagBg,
    required List<String> perks,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tag Pill + Radio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: tagColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item['tag'] as String,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Radio Ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF059669)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF059669)
                          : const Color(0xFFD1D5DB),
                      width: 2.0,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Emblem + Title + Subtitle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    size: 22,
                    color: tagColor,
                  ),
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
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: tagColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              item['description'] as String,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),

            // Perks
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: perks.map((p) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 11,
                        color: isSelected
                            ? const Color(0xFF059669)
                            : const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        p,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF059669)
                              : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Legal Trust Seal
  Widget _buildGoodSamaritanTrustSeal() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gavel_rounded, size: 16, color: Color(0xFFD97706)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Protected by the Bill Emerson Good Samaritan Food Donation Act & DPDP Act 2023. Standardized zero-liability guarantee for all verified nodes.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Dock
  Widget _buildBottomActionDock(BuildContext context) {
    final String ctaLabel = _selectedRole == UserRole.community
        ? 'Continue as Community Giver'
        : _selectedRole == UserRole.donor
            ? 'Continue as Food Donor'
            : _selectedRole == UserRole.ngo
                ? 'Continue as Verified NGO'
                : 'Continue as Platform Admin';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 5,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Primary Emerald CTA
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => widget.onRoleSelected(_selectedRole),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ctaLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Safety Micro-copy
            const Text(
              'By selecting, you agree to FoodBridge Safety Protocols & Good Samaritan Act Protections.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Language Selection Modal
  void _showLanguageDialog(BuildContext context, LocalizationService loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        title: const Row(
          children: [
            Icon(Icons.translate_rounded, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text(
              'Select Language / भाषा चुनें',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((lang) {
            final isSel = loc.currentLanguage == lang;
            return ListTile(
              dense: true,
              leading: Text(lang.flag, style: const TextStyle(fontSize: 18)),
              title: Text(
                lang.name,
                style: TextStyle(
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                  color: isSel ? const Color(0xFF059669) : const Color(0xFF111827),
                ),
              ),
              subtitle: Text(
                lang.nativeName,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              trailing: isSel
                  ? const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF059669))
                  : null,
              onTap: () {
                loc.setLanguage(lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
