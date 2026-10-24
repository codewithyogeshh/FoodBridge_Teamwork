import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../../data/repositories/app_repository.dart';

class DonationManagementScreen extends StatelessWidget {
  final AppRepository repository;

  const DonationManagementScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final donations = repository.donations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Donation Batch Moderation'),
          ),
          body: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: donations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = donations[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UrgencyBadge(level: item.urgencyLevel, compact: true),
                          const Spacer(),
                          StatusBadge(status: item.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Donor: ${item.donorName} (${item.donorPhone}) • ${item.quantityLabel}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pickup: ${item.pickupAddress}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.richCharcoal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.warmIvoryDark,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Passcode: ${item.pickupOtp}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.forestGreen,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'ID: #${item.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
