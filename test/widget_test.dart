import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/main.dart';
import 'package:foodbridge/data/repositories/app_repository.dart';
import 'package:foodbridge/data/services/supabase_service.dart';

void main() {
  testWidgets('FoodBridgeApp initial launch smoke test', (
    WidgetTester tester,
  ) async {
    final supabaseService = SupabaseService(enableRealtime: false);
    final repository = AppRepository(supabaseService: supabaseService);
    addTearDown(() {
      repository.dispose();
    });

    await tester.pumpWidget(FoodBridgeApp(repository: repository));

    // Verify FoodBridge branding appears on launch screen
    expect(find.text('FoodBridge 2.0'), findsOneWidget);

    // Pump past splash timer to onboarding
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify Onboarding appears
    expect(
      find.text('Bridge Surplus Meals to Real Community Impact'),
      findsOneWidget,
    );
  });
}
