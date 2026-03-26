import 'package:flutter_test/flutter_test.dart';
import 'package:connection_app/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UnscriptedApp());
    expect(find.text('[un]scripted'), findsOneWidget);
  });
}
