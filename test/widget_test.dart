import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:care_plus/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    // CarePlusApp is a ConsumerWidget and needs a ProviderScope ancestor.
    await tester.pumpWidget(const ProviderScope(child: CarePlusApp()));

    // Basic smoke check: the app uses MaterialApp.router under the hood.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
