import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/community_donation_model.dart';
import '../../../data/repositories/app_repository.dart';

class CommunityImpactLedgerScreen extends StatelessWidget {
  final AppRepository repository;

  const CommunityImpactLedgerScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final communityList = repository.communityDonations;
        final monetaryList = communityList
            .where((c) => c.tax80GReceiptNumber != null)
            .toList();

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Impact Ledger & 80G Receipts'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Certificate Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.emerald),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.forestGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Section 80G Tax-Deductible Records',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'All monetary contributions are authenticated and registered under Income Tax exemption rules.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.charcoalMuted,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Verified 80G Tax Certificates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (monetaryList.isEmpty) ...[
                    const AppCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No monetary contributions recorded yet. Sponsor meals to generate instant 80G certificates.',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.charcoalMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: monetaryList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = monetaryList[index];
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 16, color: AppTheme.forestGreen),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.tax80GReceiptNumber ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.forestGreen,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.emeraldLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.quantityOrAmount,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.forestGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Beneficiary: ${item.assignedNgoName}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.charcoalMuted),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.createdAt.toString().split(' ')[0],
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.charcoalMuted),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.forestGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.download_rounded,
                                        size: 14),
                                    label: const Text('Download PDF',
                                        style: TextStyle(fontSize: 11)),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Downloading official 80G Tax Exemption Certificate: ${item.tax80GReceiptNumber}'),
                                          backgroundColor:
                                              AppTheme.forestGreen,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 28),
                  const Text(
                    'Physical Items Chain-of-Custody',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.richCharcoal,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...communityList
                      .where((c) => c.tax80GReceiptNumber == null)
                      .map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.warmIvoryDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.category ==
                                        CommunityDonationCategory.clothes
                                    ? Icons.checkroom_rounded
                                    : item.category ==
                                            CommunityDonationCategory.books
                                        ? Icons.menu_book_rounded
                                        : Icons.inventory_2_rounded,
                                color: AppTheme.forestGreen,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.richCharcoal,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantityOrAmount} • ${item.status.label}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.charcoalMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppTheme.forestGreen),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
