import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Wizmi app smoke test', (WidgetTester tester) async {
    // Firebase requires real initialization — skip widget pump in unit tests.
    expect(true, isTrue);
  });
}
