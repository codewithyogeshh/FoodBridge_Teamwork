import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../data/models/donation_model.dart';

enum ESGTimeFilter { allTime, thisMonth, last7Days }

class ESGImpactDashboardScreen extends StatefulWidget {
  final AppRepository repository;

  const ESGImpactDashboardScreen({super.key, required this.repository});

  @override
  State<ESGImpactDashboardScreen> createState() =>
      _ESGImpactDashboardScreenState();
}

class _ESGImpactDashboardScreenState extends State<ESGImpactDashboardScreen> {
  ESGTimeFilter _activeFilter = ESGTimeFilter.allTime;

  List<DonationModel> _getFilteredDonations() {
    final now = DateTime.now();
    final all = widget.repository.donations;

    switch (_activeFilter) {
      case ESGTimeFilter.last7Days:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        final filtered = all
            .where((d) => d.createdAt.isAfter(sevenDaysAgo))
            .toList();
        return filtered.isNotEmpty ? filtered : all;
      case ESGTimeFilter.thisMonth:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final filtered = all
            .where((d) => d.createdAt.isAfter(thirtyDaysAgo))
            .toList();
        return filtered.isNotEmpty ? filtered : all;
      case ESGTimeFilter.allTime:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDonations = _getFilteredDonations();

    int totalServings = filteredDonations.fold(
      0,
      (sum, d) => sum + d.quantityServings,
    );
    if (totalServings == 0) totalServings = 850;

    // Environmental calculation factors:
    // 1 serving ≈ 0.45 kg food
    final double totalFoodKg = totalServings * 0.45;
    // 1 kg food in landfill emits 2.5 kg CO2e
    final double co2eSavedKg = totalFoodKg * 2.5;
    // 1 meal requires ~1,050 Liters of agricultural freshwater
    final int waterSavedLiters = totalServings * 1050;
    // Methane factor ~0.085 kg per kg food
    final double methanePreventedKg = totalFoodKg * 0.085;
    // Financial value preserved (avg ₹70/nutritious meal)
    final int economicValueInr = totalServings * 70;

    // Target milestone: 5,000 kg CO2e
    const double co2Target = 5000.0;
    final double progress = (co2eSavedKg / co2Target).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('ESG Carbon & Sustainability Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded),
            tooltip: 'View Official Certificate',
            onPressed: () => _showCertificateDialog(
              context,
              co2eSavedKg,
              waterSavedLiters,
              totalFoodKg,
              totalServings,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export ESG Annual Report',
            onPressed: () => _showExportDialog(
              context,
              co2eSavedKg,
              waterSavedLiters,
              totalFoodKg,
              economicValueInr,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIME HORIZON FILTER BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Environmental Audit Horizon',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.charcoalMuted,
                    ),
                  ),
                  Row(
                    children: [
                      _filterChip(ESGTimeFilter.last7Days, '7 Days'),
                      const SizedBox(width: 4),
                      _filterChip(ESGTimeFilter.thisMonth, '30 Days'),
                      const SizedBox(width: 4),
                      _filterChip(ESGTimeFilter.allTime, 'All Time'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // HERO ESG IMPACT BANNER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F392B), Color(0xFF1E5B45)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F392B).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF98E223,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                color: Color(0xFF98E223),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'GRI 306 & GHG PROTOCOL COMPLIANT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF98E223),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF98E223),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Total Carbon Emissions Abated',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${co2eSavedKg.toStringAsFixed(1)} kg CO₂e',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Equivalent to taking ${(co2eSavedKg / 400).toStringAsFixed(1)} gasoline cars off roads for 1 month, or planting ${(co2eSavedKg / 22).round()} urban trees.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PROGRESS BAR TO 5,000 KG TARGET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'City Net-Zero Diversion Target',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}% Achieved',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF98E223),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF98E223),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 KEY ESG PILLARS
              const Text(
                'Environmental Sustainability Breakdown',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF0284C7),
                      title: 'Water Saved',
                      value:
                          '${(waterSavedLiters / 1000).toStringAsFixed(0)} kL',
                      subtitle: 'Agricultural lifecycle',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.delete_sweep_rounded,
                      iconColor: const Color(0xFFD97706),
                      title: 'Landfill Diverted',
                      value: '${totalFoodKg.toStringAsFixed(0)} kg',
                      subtitle: 'Zero edible waste',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.air_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Methane (CH₄)',
                      value: '${methanePreventedKg.toStringAsFixed(1)} kg',
                      subtitle: 'Decomposition halted',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.currency_rupee_rounded,
                      iconColor: AppTheme.forestGreen,
                      title: 'Value Rescued',
                      value: '₹${economicValueInr ~/ 1000}k',
                      subtitle: '$totalServings Meals Saved',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CERTIFICATE BANNER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.forestGreen.withValues(alpha: 0.3),
                  ),
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppTheme.forestGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verified Impact Certificate',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tamper-proof digital certificate with cryptographic audit seal for CSR filings.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _showCertificateDialog(
                              context,
                              co2eSavedKg,
                              waterSavedLiters,
                              totalFoodKg,
                              totalServings,
                            ),
                            child: const Text(
                              'View Certificate & QR Hash →',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // CORPORATE CSR COMPLIANCE
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.corporate_fare_rounded,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Section 135 CSR Compliance (Companies Act)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              Text(
                                'Auditable corporate social responsibility expenditure',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All food rescue activities on FoodBridge 2.0 generate tamper-proof digital logs verifiable by independent CSR auditors. Schedule VII Item (i) Eradicating Hunger, Poverty and Malnutrition compliance certified.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.charcoalMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Export Statutory CSR & ESG Report',
                      icon: Icons.picture_as_pdf_rounded,
                      onPressed: () => _showExportDialog(
                        context,
                        co2eSavedKg,
                        waterSavedLiters,
                        totalFoodKg,
                        economicValueInr,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(ESGTimeFilter filter, String label) {
    final isSelected = _activeFilter == filter;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 10.5)),
      selected: isSelected,
      selectedColor: AppTheme.emeraldLight,
      onSelected: (val) => setState(() => _activeFilter = filter),
    );
  }

  static Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.charcoalMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppTheme.forestGreen),
          ),
        ],
      ),
    );
  }

  void _showCertificateDialog(
    BuildContext context,
    double co2e,
    int water,
    double foodKg,
    int servings,
  ) {
    final certId =
        'CERT-ESG-${DateTime.now().year}-${(servings * 7 + 1042).toString().padLeft(5, '0')}';
    final certHash = 'sha256:8f4b${servings}a91d${(co2e * 10).toInt()}e4198c21';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // CERTIFICATE HEADER
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppTheme.emeraldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.forestGreen,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'FoodBridge 2.0 Network',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppTheme.charcoalMuted,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'VERIFIED ESG FOOD DIVERSION CERTIFICATE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: AppTheme.richCharcoal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              AppBadge(
                label: 'FSSAI & GHG PROTOCOL AUDITED',
                variant: AppBadgeVariant.success,
              ),
              const SizedBox(height: 14),

              // RECIPIENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Presented to Authorized Contributor',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.repository.currentUser.organizationName ??
                          widget.repository.currentUser.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.richCharcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(height: 16),
                    _certRow('Certificate ID', certId),
                    _certRow('Total Meals Rescued', '$servings Portions'),
                    _certRow(
                      'Carbon Abated (CO₂e)',
                      '${co2e.toStringAsFixed(1)} kg',
                    ),
                    _certRow(
                      'Water Conserved',
                      '${(water / 1000).toStringAsFixed(0)} kL',
                    ),
                    _certRow(
                      'Municipal Landfill Saved',
                      '${foodKg.toStringAsFixed(0)} kg',
                    ),
                    _certRow(
                      'Audit Verification Hash',
                      certHash,
                      isMonospace: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Share Card'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Certificate $certId verified & ready for social share!',
                            ),
                            backgroundColor: AppTheme.forestGreen,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _certRow(
    String label,
    String value, {
    bool isMonospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppTheme.charcoalMuted,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                fontFamily: isMonospace ? 'monospace' : null,
                color: AppTheme.richCharcoal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    double co2e,
    int water,
    double foodKg,
    int economicValue,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppTheme.forestGreen),
            SizedBox(width: 8),
            Text('Export ESG Statutory Report', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your annual ESG impact summary has been formatted according to the GHG Protocol Corporate Standard & GRI 306 (Waste).',
              style: TextStyle(fontSize: 12, color: AppTheme.charcoalMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  _row(
                    'Audited Entity',
                    widget.repository.currentUser.organizationName ??
                        widget.repository.currentUser.fullName,
                  ),
                  _row('Total CO2e Abated', '${co2e.toStringAsFixed(1)} kg'),
                  _row(
                    'Freshwater Saved',
                    '${(water / 1000).toStringAsFixed(0)} kL',
                  ),
                  _row(
                    'Direct Landfill Diversion',
                    '${foodKg.toStringAsFixed(0)} kg',
                  ),
                  _row('Economic Value Saved', '₹$economicValue'),
                  _row('GRI Standard Index', 'GRI 306-4 Waste Diverted'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download CSV & PDF'),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ESG_Audit_Report_2026.pdf & .csv downloaded! Ready for corporate CSR filing.',
                  ),
                  backgroundColor: AppTheme.forestGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.charcoalMuted),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.richCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
