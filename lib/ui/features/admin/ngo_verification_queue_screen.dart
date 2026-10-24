import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/state_widgets.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'ngo_verification_detail_screen.dart';

class NGOVerificationQueueScreen extends StatefulWidget {
  final AppRepository repository;

  const NGOVerificationQueueScreen({super.key, required this.repository});

  @override
  State<NGOVerificationQueueScreen> createState() =>
      _NGOVerificationQueueScreenState();
}

class _NGOVerificationQueueScreenState
    extends State<NGOVerificationQueueScreen> {
  bool _filterPendingOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final allNGOs = widget.repository.ngos;
        final list = _filterPendingOnly
            ? allNGOs
                  .where(
                    (n) =>
                        n.verificationStatus == NGOVerificationStatus.pending,
                  )
                  .toList()
            : allNGOs;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(title: const Text('NGO Verification Queue')),
          body: SafeArea(
            child: Column(
              children: [
                // Filter Tabs
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text('All Organizations (${allNGOs.length})'),
                        selected: !_filterPendingOnly,
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (val) {
                          if (val) setState(() => _filterPendingOnly = false);
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(
                          'Pending Review (${widget.repository.pendingNGOs.length})',
                        ),
                        selected: _filterPendingOnly,
                        selectedColor: const Color(0xFFFEF3C7),
                        onSelected: (val) {
                          if (val) setState(() => _filterPendingOnly = true);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.borderColor),

                // NGO List
                Expanded(
                  child: list.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.task_alt_rounded,
                          title: 'Verification Queue Clear',
                          message:
                              'All submitted NGO applications have been audited and resolved.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return AppCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NGOVerificationDetailScreen(
                                          ngo: item,
                                          repository: widget.repository,
                                        ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: item.isVerified
                                          ? AppTheme.emeraldLight
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      item.isVerified
                                          ? Icons.verified_rounded
                                          : Icons.hourglass_top_rounded,
                                      color: item.isVerified
                                          ? AppTheme.forestGreen
                                          : const Color(0xFFD97706),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.organizationName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.richCharcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Reg: ${item.registrationNumber} • ${item.capacityMealsPerDay} meals/day',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.charcoalMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.charcoalLight,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
