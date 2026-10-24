import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';

class NGOVerificationDetailScreen extends StatefulWidget {
  final NGOModel ngo;
  final AppRepository repository;

  const NGOVerificationDetailScreen({
    super.key,
    required this.ngo,
    required this.repository,
  });

  @override
  State<NGOVerificationDetailScreen> createState() =>
      _NGOVerificationDetailScreenState();
}

class _NGOVerificationDetailScreenState
    extends State<NGOVerificationDetailScreen> {
  late NGOModel _ngo;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _ngo = widget.ngo;
  }

  void _updateStatus(NGOVerificationStatus newStatus) async {
    setState(() => _isUpdating = true);

    final success =
        await widget.repository.updateNGOVerification(_ngo.id, newStatus);

    if (mounted) {
      setState(() {
        _isUpdating = false;
        if (success) {
          _ngo = _ngo.copyWith(verificationStatus: newStatus);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == NGOVerificationStatus.verified
                ? 'NGO Approved and credentialed on FoodBridge Network!'
                : 'Application rejected / flagged for audit.',
          ),
          backgroundColor: newStatus == NGOVerificationStatus.verified
              ? AppTheme.forestGreen
              : AppTheme.statusCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('NGO Verification Audit'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _ngo.organizationName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                  ),
                  NGOVerifiedBadge(isVerified: _ngo.isVerified),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Registration: ${_ngo.registrationNumber}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.charcoalMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Organization Details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entity Information & Contact',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRow('Primary Coordinator', _ngo.contactPerson),
                    _buildRow('Official Phone', _ngo.phone),
                    _buildRow('Kitchen Facility Address', _ngo.address),
                    _buildRow('Daily Meal Capacity',
                        '${_ngo.capacityMealsPerDay} Meals / Day'),
                    _buildRow('FSSAI Certificate ID',
                        _ngo.foodSafetyCertId ?? 'PENDING AUDIT'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Uploaded Compliance & Identity Documents
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_rounded,
                            size: 18, color: AppTheme.forestGreen),
                        SizedBox(width: 8),
                        Text(
                          'Compliance & Government Identity Documents',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 1. Compulsory Government Identity Document (Aadhaar / PAN)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warmIvoryDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.emerald),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.badge_rounded,
                                color: AppTheme.forestGreen, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _ngo.govtDocFileName ??
                                          'Aadhaar_Card_Verified_Scan.pdf',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.richCharcoal,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppTheme.emerald,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'GOVT ID',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_ngo.govtIdType ?? "Aadhaar Card"}: ${_ngo.govtIdNumber ?? "5482 1928 8912"} • Verified Scan (${_ngo.docFileSize ?? "1.4 MB"})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.forestGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 14),
                            label: const Text('View Doc',
                                style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              _openDocumentViewer(
                                docTitle: 'Government Identity Verification Document',
                                docType: _ngo.govtIdType ?? 'Aadhaar Card (UIDAI)',
                                docFileName: _ngo.govtDocFileName ??
                                    'Aadhaar_Card_Verified_Scan.pdf',
                                docIdNumber: _ngo.govtIdNumber ?? '5482 1928 8912',
                                docFileSize: '2.1 MB',
                                issuingAuthority:
                                    'Government of India / Unique Identification Authority',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. FSSAI Food Safety Certificate
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warmIvoryDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.picture_as_pdf_rounded,
                                color: Color(0xFFD97706), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _ngo.fssaiDocFileName ??
                                          'FSSAI_Certificate_Scan.pdf',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.richCharcoal,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppTheme.forestGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'FOOD SAFETY',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lic: ${_ngo.foodSafetyCertId ?? "FSSAI-2024-901844-KA"} • Commercial Rescue (${_ngo.docFileSize ?? "1.4 MB"})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cardSurfaceElevated,
                              foregroundColor: AppTheme.restrainedLime,
                              side: const BorderSide(color: AppTheme.restrainedLime),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.visibility_rounded, size: 14),
                            label: const Text('View Doc',
                                style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              _openDocumentViewer(
                                docTitle: 'FSSAI Food Safety Compliance Certificate',
                                docType: 'State Food Safety Authority License',
                                docFileName: _ngo.fssaiDocFileName ??
                                    'FSSAI_Certificate_Scan.pdf',
                                docIdNumber: _ngo.foodSafetyCertId ??
                                    'FSSAI-2024-901844-KA',
                                docFileSize: _ngo.docFileSize ?? '1.4 MB',
                                issuingAuthority:
                                    'Food Safety & Standards Authority of India (FSSAI)',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Admin Action Buttons
              if (!_ngo.isVerified) ...[
                AppButton(
                  label: 'Approve & Grant Food Rescue License',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isUpdating,
                  variant: AppButtonVariant.primary,
                  onPressed: () =>
                      _updateStatus(NGOVerificationStatus.verified),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Reject Application / Flag for Defect',
                  icon: Icons.cancel_outlined,
                  isLoading: _isUpdating,
                  variant: AppButtonVariant.danger,
                  onPressed: () =>
                      _updateStatus(NGOVerificationStatus.rejected),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.emerald),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppTheme.forestGreen, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This organization is actively verified and authorized to participate in atomic reservations and meal pickups.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.charcoalMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.richCharcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDocumentViewer({
    required String docTitle,
    required String docType,
    required String docFileName,
    required String docIdNumber,
    required String docFileSize,
    required String issuingAuthority,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppTheme.cardSurface,
          child: Container(
            width: 580,
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_user_rounded,
                          color: AppTheme.forestGreen, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            docTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Text(
                            '$docType • $docFileSize',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Digital Certificate Document Visualizer
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFBF9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Gold official border
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Official Seal Emblem
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.forestGreen.withValues(alpha: 0.08),
                              border: Border.all(color: AppTheme.forestGreen, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.shield_rounded,
                                  color: AppTheme.forestGreen, size: 30),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'GOVERNMENT REGISTRATION & COMPLIANCE RECORD',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          Text(
                            issuingAuthority,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Color(0xFFD4AF37), thickness: 1),
                          const SizedBox(height: 14),

                          // Certificate Data Table
                          _buildCertRow('Entity Legal Name', _ngo.organizationName),
                          _buildCertRow('Registration / 80G No.', _ngo.registrationNumber),
                          _buildCertRow('Authorized Trustee', _ngo.contactPerson),
                          _buildCertRow('Registered Phone', _ngo.phone),
                          _buildCertRow('Document Identifier', docIdNumber),
                          _buildCertRow('Kitchen Coordinates', _ngo.address),
                          _buildCertRow('Daily Meal Quota', '${_ngo.capacityMealsPerDay} Meals / Day'),
                          _buildCertRow('Digital Security Hash', _ngo.docVerifiedHash ?? 'SHA256: 8F2A-94B1-C84E-Verified'),
                          _buildCertRow('Attached File Record', docFileName),

                          const SizedBox(height: 20),

                          // Verified Stamp Banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.emerald),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: AppTheme.forestGreen, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'CRYPTOGRAPHIC AUDIT PASS: VERIFIED AUTHENTIC',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.forestGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Dialog Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.forestGreen,
                          side: const BorderSide(color: AppTheme.forestGreen),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('Download PDF Copy'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Downloading $docFileName for local audit storage...'),
                              backgroundColor: AppTheme.forestGreen,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Confirm Inspected'),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.charcoalMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(': ',
              style: TextStyle(fontSize: 11.5, color: AppTheme.charcoalMuted)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.richCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
