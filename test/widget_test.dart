import 'package:flutter_test/flutter_test.dart';
import 'package:untitled2/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KienCareApp());

    // Verify that the app builds without crashing.
    expect(find.byType(KienCareApp), findsOneWidget);
  });
}
