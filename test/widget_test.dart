import 'package:flutter_test/flutter_test.dart';
import 'package:emergencyos_innotionx_hackathon/main.dart';

void main() {
  testWidgets('basic widgets are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const EmergencyOsApp());

    expect(find.text('Emergency Dashboard'), findsOneWidget);
    expect(find.text('Send Report'), findsOneWidget);
    expect(find.text('Siren is OFF'), findsOneWidget);
  });
}
