import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../../data/services/dispatch_webhook_service.dart';

class WhatsAppDispatchDialog extends StatelessWidget {
  const WhatsAppDispatchDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const WhatsAppDispatchDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dispatch = DispatchWebhookService.instance;

    return ListenableBuilder(
      listenable: dispatch,
      builder: (context, _) {
        final alerts = dispatch.alerts;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppTheme.cardSurface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF25D366,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Color(0xFF128C7E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp & SMS Dispatch Bot',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                            Text(
                              'Real-time webhook dispatches to 3 nearest shelter drivers',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF16A34A),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cooked food expires in < 3 hrs. Field staff receive instant WhatsApp deep-links with 1-tap atomic claim locks.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF166534),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Broadcast Dispatches',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.richCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: alerts.isEmpty
                        ? const Center(
                            child: Text(
                              'No active WhatsApp dispatches',
                              style: TextStyle(color: AppTheme.charcoalMuted),
                            ),
                          )
                        : ListView.separated(
                            itemCount: alerts.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = alerts[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FDF9),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: item.isClaimed
                                        ? AppTheme.borderColor
                                        : const Color(
                                            0xFF25D366,
                                          ).withValues(alpha: 0.5),
                                    width: item.isClaimed ? 1 : 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone_android_rounded,
                                              size: 14,
                                              color: Color(0xFF128C7E),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.recipientNgo,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.richCharcoal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: item.isClaimed
                                                ? Colors.grey.shade200
                                                : const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            item.isClaimed
                                                ? 'CLAIMED'
                                                : 'AWAITING CLAIM',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: item.isClaimed
                                                  ? Colors.grey.shade700
                                                  : const Color(0xFF15803D),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        item.formattedMessage,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          color: AppTheme.richCharcoal,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (!item.isClaimed)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              size: 14,
                                            ),
                                            label: const Text(
                                              'Simulate 1-Tap Claim',
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFF128C7E,
                                              ),
                                            ),
                                            onPressed: () {
                                              dispatch.claimAlert(item.id);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Pickup locked by ${item.recipientNgo}! Atomic lock active.',
                                                  ),
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
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Trigger Test Alert (Nearest Kitchens)',
                    icon: Icons.send_rounded,
                    onPressed: () {
                      dispatch.triggerSurplusAlert(
                        donationTitle: '75 Packaged Rice & Dal Meals',
                        donorName: 'The Leela Palace Kitchens',
                        location: 'Old Airport Road, Ward 12',
                        safeUntilText: 'In 2 hrs 45 mins',
                        servings: 75,
                        ngoName: 'Annam Kitchen & Shelter Trust',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'WhatsApp Webhook dispatched to 3 closest verified NGOs!',
                          ),
                          backgroundColor: Color(0xFF128C7E),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
