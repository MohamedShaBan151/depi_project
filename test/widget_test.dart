import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noon_clone/main.dart';


void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Wait for all animations and async tasks
    await tester.pumpAndSettle();

    // Verify app loaded (MaterialApp exists)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}