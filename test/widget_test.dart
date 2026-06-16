import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const KienCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the app builds without crashing.
    expect(find.byType(KienCareApp), findsOneWidget);
  });
}
