import 'package:draw_canvas_and_animations/animation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnimationPage should render correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AnimationPage()));

    // Verify that the heart icon is present.
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // Verify that the progress bar is present.
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify that the reset button is present.
    expect(find.widgetWithText(ElevatedButton, 'Reset'), findsOneWidget);
  });

  testWidgets('AnimationPage should update progress on heart tap', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AnimationPage()));

    // Verify that the initial progress is 0.0.
    expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        0.0);

    // Tap the heart icon.
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    // Verify that the progress is updated.
    expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        greaterThan(0.0));
  });

  testWidgets('AnimationPage should reset progress on reset button tap', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AnimationPage()));

    // Tap the heart icon to update the progress.
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    // Verify that the progress is updated.
    expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        greaterThan(0.0));

    // Tap the reset button.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Reset'));
    await tester.pumpAndSettle();

    // Verify that the progress is reset to 0.0.
    expect(
        tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
        0.0);
  });
}