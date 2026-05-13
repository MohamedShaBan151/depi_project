import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noon_clone/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ECommerceApp());

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
