import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patient_app/models/patient_model.dart';
import 'package:patient_app/screens/patient_home_screen.dart';

void main() {
  testWidgets('Patient home builds with demo profile', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatientHomeScreen(
          patient: const PatientModel(
            uid: 'test',
            name: 'Test',
            email: 'test@test.com',
            phone: '0',
          ),
          onSignedOut: () async {},
        ),
      ),
    );
    expect(find.textContaining('EmergencyOS'), findsWidgets);
  });
}
