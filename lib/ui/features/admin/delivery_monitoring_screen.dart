import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/map_preview_widget.dart';
import '../../../data/repositories/app_repository.dart';
import '../logistics/whatsapp_dispatch_dialog.dart';

class DeliveryMonitoringScreen extends StatelessWidget {
  final AppRepository repository;

  const DeliveryMonitoringScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final activeReserved = repository.activeReservedDonations;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Live Delivery Map'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_rounded, color: Color(0xFF16A34A)),
                tooltip: 'WhatsApp & SMS Alerts',
                onPressed: () => WhatsAppDispatchDialog.show(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Map Surface
                  MapPreviewWidget(
                    height: 260,
                    locationTitle: 'Live Deliveries',
                    subtitle: '${activeReserved.length} active trip(s)',
                    showRoute: true,
                    destinationTitle: activeReserved.isNotEmpty
                        ? (activeReserved.first.reservedNgoName ??
                              'Partner NGO')
                        : 'Partner NGO',
                  ),
                  const SizedBox(height: 24),

                  // Operations Status Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ongoing Deliveries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '98% ON TIME',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (activeReserved.isEmpty)
                    const Text('No active deliveries right now.')
                  else
                    ...activeReserved.map((item) {
                      final driverLabel =
                          item.assignedVolunteerName ??
                          '${item.reservedNgoName ?? "NGO"} Team';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          border: const BorderSide(
                            color: AppTheme.emerald,
                            width: 1.5,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.emeraldLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'ON THE WAY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.forestGreen,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    'About 11 mins',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.forestGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Helper: $driverLabel • To: ${item.reservedNgoName ?? "NGO Kitchen"}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.warmIvoryDark,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 14,
                                      color: AppTheme.statusCritical,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Best before: ${item.formattedTimeRemaining}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.statusCritical,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
