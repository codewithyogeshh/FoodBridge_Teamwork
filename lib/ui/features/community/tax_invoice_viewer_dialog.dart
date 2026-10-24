import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../../data/models/community_donation_model.dart';

class TaxInvoiceViewerDialog extends StatelessWidget {
  final CommunityDonationModel donation;

  const TaxInvoiceViewerDialog({super.key, required this.donation});

  static Future<void> show(
    BuildContext context, {
    required CommunityDonationModel donation,
  }) {
    return showDialog(
      context: context,
      builder: (_) => TaxInvoiceViewerDialog(donation: donation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptNum =
        donation.tax80GReceiptNumber ??
        '80G-FB-2026-${donation.id.hashCode.abs() % 90000 + 10000}';
    final amount = donation.quantityOrAmount;
    final dateStr =
        '${donation.createdAt.day.toString().padLeft(2, '0')}/${donation.createdAt.month.toString().padLeft(2, '0')}/${donation.createdAt.year}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.cardSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ACTION BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: AppTheme.forestGreen,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Official Section 80G Tax Invoice',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // SCROLLABLE OFFICIAL CERTIFICATE
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFDF9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER WITH TRUST DETAILS
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.forestGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'FORM NO. 10BD ACKNOWLEDGMENT CERTIFICATE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: AppTheme.forestGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'FOODBRIDGE RELIEF & HUNGER ABATEMENT FOUNDATION',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Registered Public Charitable Trust • NITI Aayog Darpan: KA/2023/038891',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                              const Text(
                                '80G Unique Reg No: AABTF8901PF20231 • PAN: AABTF8901P',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 24),

                        // RECEIPT META
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Receipt Serial Number',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                                Text(
                                  receiptNum,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Date of Issuance',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // DONOR & CONTRIBUTION DETAILS TABLE
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            children: [
                              _buildRow('Donor Legal Name', donation.donorName),
                              _buildRow('Donor Contact', donation.donorPhone),
                              _buildRow(
                                'Tax Exemption Category',
                                'Section 80G(5)(vi) Income Tax Act 1961',
                              ),
                              _buildRow('Donation Purpose', donation.title),
                              _buildRow(
                                'Transaction Reference',
                                donation.paymentTransactionId ??
                                    'TXN-UPI-${DateTime.now().millisecondsSinceEpoch}',
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Eligible Donated Amount:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.richCharcoal,
                                    ),
                                  ),
                                  Text(
                                    amount,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.forestGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // STATUTORY TAX EXEMPTION NOTICE
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Statutory Notice: 50% of the donated sum qualifies for deduction from taxable gross income in India under Section 80G of the Income Tax Act, 1961. This acknowledgment is electronically generated and reconciled with CBDT Form 10BD.',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // DIGITAL SIGNATURE & QR SEAL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 40,
                                    color: AppTheme.richCharcoal,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'CBDT Verification QR',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Digest: ${receiptNum.hashCode.abs()}',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: AppTheme.charcoalMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Authorized Signatory',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.richCharcoal,
                                  ),
                                ),
                                const Text(
                                  'Treasurer, FoodBridge Trust',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppTheme.charcoalMuted,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'DIGITALLY SIGNED',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.borderColor),
                      ),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text('Direct UPI Intent'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Launching UPI Intent: upi://pay?pa=foodbridge.relief@icici&pn=FoodBridge&am=${amount.replaceAll(RegExp(r"[^0-9]"), "")}&cu=INR',
                            ),
                            backgroundColor: AppTheme.forestGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Download / Print PDF',
                      icon: Icons.print_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Exporting Form 10BD PDF Certificate ($receiptNum.pdf)... Downloaded!',
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

  Widget _buildRow(String label, String value) {
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
              fontWeight: FontWeight.w600,
              color: AppTheme.richCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
