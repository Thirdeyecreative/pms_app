import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pms_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PmsApp());
    // App should render without error
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
