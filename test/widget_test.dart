// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Wealth Ninja app smoke test', (WidgetTester tester) async {
    // Build a simple material app for testing
    await tester.pumpWidget(MaterialApp(
      title: 'Wealth Ninja Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Wealth Ninja')),
        body: const Center(
          child: Text('Track your wealth like a ninja'),
        ),
      ),
    ));

    // Verify that the app shows the expected content
    expect(find.text('Wealth Ninja'), findsOneWidget);
    expect(find.text('Track your wealth like a ninja'), findsOneWidget);
  });
}
