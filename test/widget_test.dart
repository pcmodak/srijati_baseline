import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srijati_baseline/main.dart';

void main() {
  testWidgets('Srijati Baseline app loads login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SrijatiApp());
    await tester.pumpAndSettle();

    expect(find.text('Srijati Foundation'), findsOneWidget);
    expect(find.text('Baseline Livelihood Survey MIS'), findsOneWidget);
  });
}
