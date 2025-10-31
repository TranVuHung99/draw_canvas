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
            of: find.byKey(const Key('drawing_canvas')),
            matching: find.byType(CustomPaint)),
        findsOneWidget);
  });

  testWidgets('DrawingCanvas speed dial should manage drawing modes and close on outside tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // --- Initial State: Draw Mode ---
    // Verify main FAB shows brush icon (default draw mode) and speed dial is closed.
    expect(find.byIcon(Icons.brush), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing); // Speed dial is closed
    expect(find.byKey(const Key('clear_button')), findsNothing); // Child FABs are hidden
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'drawFab'), findsNothing);
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'eraseFab'), findsNothing);

    // --- Open Speed Dial ---
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'mainFab'));
    await tester.pumpAndSettle();

    // Verify main FAB shows close icon and child FABs are visible.
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byKey(const Key('clear_button')), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'drawFab'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'eraseFab'), findsOneWidget);

    // --- Select Erase Mode ---
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'eraseFab'));
    await tester.pumpAndSettle();

    // Verify main FAB shows cleaning_services icon (erase mode) and speed dial is closed.
    expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing); // Speed dial is closed
    expect(find.byKey(const Key('clear_button')), findsNothing); // Child FABs are hidden

    // --- Open Speed Dial Again ---
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'mainFab'));
    await tester.pumpAndSettle();

    // Verify main FAB shows close icon and child FABs are visible.
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byKey(const Key('clear_button')), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'drawFab'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'eraseFab'), findsOneWidget);

    // --- Select Draw Mode ---
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'drawFab'));
    await tester.pumpAndSettle();

    // Verify main FAB shows brush icon (draw mode) and speed dial is closed.
    expect(find.byIcon(Icons.brush), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing); // Speed dial is closed
    expect(find.byKey(const Key('clear_button')), findsNothing); // Child FABs are hidden

    // --- Test Outside Tap ---
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'mainFab')); // Open speed dial
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsOneWidget); // Verify open

    // Tap outside the speed dial (e.g., on the canvas)
    await tester.tap(find.byKey(const Key('drawing_canvas')));
    await tester.pumpAndSettle();

    // Verify speed dial is closed and main FAB shows brush icon (still in draw mode).
    expect(find.byIcon(Icons.brush), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing); // Speed dial is closed
    expect(find.byKey(const Key('clear_button')), findsNothing); // Child FABs are hidden
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

  testWidgets('DrawingCanvas should draw and erase points on pan update',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));

    // Simulate a pan gesture to draw a line.
    await tester.drag(find.byKey(const Key('drawing_canvas')), const Offset(200, 200));
    await tester.pump();

    // Find the CustomPaint widget and get its painter.
    final CustomPaint customPaint = tester.widget(find.descendant(
        of: find.byKey(const Key('drawing_canvas')),
        matching: find.byType(CustomPaint)));
    final DrawingPainter painter = customPaint.painter as DrawingPainter;

    // Verify that the points list is not empty and the last point is not for erasing.
    expect(painter.points.isNotEmpty, isTrue);
    final lastPoint = painter.points.where((p) => p != null).last;
    expect(lastPoint!.isErasing, isFalse);

    final initialPointsCount = painter.points.length;

    // Tap the main FAB to open the Speed Dial.
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'mainFab'));
    await tester.pumpAndSettle();

    // Tap the erase FAB to toggle erase mode.
    await tester.tap(find.byIcon(Icons.cleaning_services));
    await tester.pumpAndSettle();

    // Simulate another pan gesture to erase a line.
    await tester.drag(find.byKey(const Key('drawing_canvas')), const Offset(300, 300));
    await tester.pump();

    // Find the CustomPaint widget again and get its painter.
    final CustomPaint customPaint2 = tester.widget(find.descendant(
        of: find.byKey(const Key('drawing_canvas')),
        matching: find.byType(CustomPaint)));
    final DrawingPainter painter2 = customPaint2.painter as DrawingPainter;

    // Verify that the points list has more points and the last point is for erasing.
    expect(painter2.points.length, greaterThan(initialPointsCount));
    final lastPoint2 = painter2.points.where((p) => p != null).last;
    expect(lastPoint2!.isErasing, isTrue);
  });

  testWidgets('DrawingCanvas should add sticker on drag and drop',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));
    await tester.pumpAndSettle();

    // Find the first sticker in the palette.
    final stickerFinder = find.byType(Draggable<String>);
    expect(stickerFinder, findsWidgets);

    final firstSticker = stickerFinder.first;

    // Find the canvas.
    final canvasFinder = find.byKey(const Key('drawing_canvas'));
    expect(canvasFinder, findsOneWidget);

    // Drag the sticker to the canvas.
    await tester.drag(firstSticker, tester.getCenter(canvasFinder) - tester.getCenter(firstSticker));
    await tester.pump();

    // Find the CustomPaint widget and get its painter.
    final CustomPaint customPaint = tester.widget(find.descendant(
        of: find.byKey(const Key('drawing_canvas')),
        matching: find.byType(CustomPaint)));
    final DrawingPainter painter = customPaint.painter as DrawingPainter;

    // Verify that a sticker has been added.
    expect(painter.stickers.length, 1);
  });

  testWidgets('DrawingCanvas should clear all drawings and stickers when clear button is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrawingCanvas()));
    await tester.pumpAndSettle();

    // Simulate drawing
    await tester.drag(find.byKey(const Key('drawing_canvas')), const Offset(100, 100));
    await tester.pump();

    // Simulate adding a sticker
    final stickerFinder = find.byType(Draggable<String>);
    await tester.drag(stickerFinder.first, tester.getCenter(find.byKey(const Key('drawing_canvas'))) - tester.getCenter(stickerFinder.first));
    await tester.pump();

    // Get the painter to check initial state
    final CustomPaint customPaint = tester.widget(find.descendant(
        of: find.byKey(const Key('drawing_canvas')),
        matching: find.byType(CustomPaint)));
    final DrawingPainter painter = customPaint.painter as DrawingPainter;

    // Verify that points and stickers are not empty
    expect(painter.points.isNotEmpty, isTrue);
    expect(painter.stickers.isNotEmpty, isTrue);

    // Simulate tapping the main FAB to open the Speed Dial.
    await tester.tap(find.byWidgetPredicate((widget) => widget is FloatingActionButton && widget.heroTag == 'mainFab'));
    await tester.pumpAndSettle();

    // Simulate tapping the clear FAB.
    await tester.tap(find.byKey(const Key('clear_button')));
    await tester.pumpAndSettle();

    // Verify that points and stickers are empty after clearing
    expect(painter.points.isEmpty, isTrue);
    expect(painter.stickers.isEmpty, isTrue);
  });
}