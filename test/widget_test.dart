import 'package:flutter_test/flutter_test.dart';
import 'package:care_plus/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const CarePlusApp());
    expect(find.byType(CarePlusApp), findsOneWidget);
  });
}
