import 'package:draw_canvas_and_animations/draw_canvas_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DrawingCanvas should render CustomPaint',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // Verify that our canvas renders a CustomPaint widget.
    expect(
        find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint)),
        findsOneWidget);
  });

  testWidgets('DrawingCanvas should toggle erase mode',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // Verify that the initial icon is cleaning_services.
    expect(find.byIcon(Icons.cleaning_services), findsOneWidget);

    // Tap the erase button.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Verify that the icon has changed to brush.
    expect(find.byIcon(Icons.brush), findsOneWidget);

    // Tap the erase button again.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Verify that the icon has changed back to cleaning_services.
    expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
  });
}
