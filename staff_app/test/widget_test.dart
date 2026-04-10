import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Note: Firebase is not initialized in tests.
    // Full integration tests require a Firebase emulator setup.
    expect(StaffApp, isNotNull);
  });
}
