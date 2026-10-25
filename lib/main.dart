import 'package:flutter/material.dart';
import 'ui/core/theme.dart';
import 'ui/core/constants.dart';
import 'ui/core/widgets/notification_banner_overlay.dart';
import 'ui/core/widgets/notification_center_sheet.dart';
import 'ui/core/navigation/app_root_flow.dart';
import 'ui/features/ngo/donation_details_screen.dart';
import 'data/repositories/app_repository.dart';

export 'ui/core/navigation/app_root_flow.dart' show AppFlowStep;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppRepository();
  runApp(FoodBridgeApp(repository: repository));
}

class FoodBridgeApp extends StatelessWidget {
  final AppRepository repository;
  final AppFlowStep initialStep;

  const FoodBridgeApp({
    super.key,
    required this.repository,
    this.initialStep = AppFlowStep.splash,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return RealtimeNotificationOverlay(
          repository: repository,
          onActionTap: (notif) {
            final donationId = notif.metadata['donation_id'] ?? notif.entityId;
            if (donationId != null && donationId.toString().isNotEmpty) {
              final donations = repository.donations;
              final found = donations
                  .where((d) => d.id == donationId.toString())
                  .toList();
              final donation = found.isNotEmpty
                  ? found.first
                  : (repository.availableDonations.isNotEmpty
                        ? repository.availableDonations.first
                        : (donations.isNotEmpty ? donations.first : null));
              if (donation != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => DonationDetailsScreen(
                      donation: donation,
                      repository: repository,
                    ),
                  ),
                );
                return;
              }
            }
            NotificationCenterSheet.show(context, repository: repository);
          },
          child: child ?? const SizedBox(),
        );
      },
      home: AppRootFlow(repository: repository, initialStep: initialStep),
    );
  }
}
