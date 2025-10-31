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

  testWidgets('DrawingCanvas should open drawer and have a slider',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // Open the drawer.
    await tester.dragFrom(
        tester.getTopLeft(find.byType(MaterialApp)), const Offset(300, 0));
    await tester.pumpAndSettle();

    // Verify that the drawer is open.
    expect(find.byType(Drawer), findsOneWidget);

    // Verify that the slider is present in the drawer.
    expect(find.descendant(of: find.byType(Drawer), matching: find.byType(Slider)),
        findsOneWidget);
  });

  testWidgets('DrawingCanvas should update stroke width when slider is changed',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // Open the drawer.
    await tester.dragFrom(
        tester.getTopLeft(find.byType(MaterialApp)), const Offset(300, 0));
    await tester.pumpAndSettle();

    // Verify that the initial stroke width is 5.0.
    expect(find.text('Stroke: 5.0'), findsOneWidget);

    // Change the slider value.
    await tester.tap(find.byType(Slider));
    await tester.pump();

    // Verify that the stroke width text is updated.
    // The new value is not deterministic, so we check that it's not 5.0 anymore.
    expect(find.text('Stroke: 5.0'), findsNothing);
  });
}