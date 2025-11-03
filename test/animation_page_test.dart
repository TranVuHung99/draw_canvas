import 'package:draw_canvas_and_animations/animation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Progress bar updates on heart selection', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AnimationPage()));

    final animatedContainer = find.byType(AnimatedContainer);
    expect(animatedContainer, findsOneWidget);

    var container = tester.widget<AnimatedContainer>(animatedContainer);
    expect(container.constraints!.maxWidth, 0);

    await tester.tap(find.byIcon(Icons.favorite).first);
    await tester.pumpAndSettle();

    container = tester.widget<AnimatedContainer>(animatedContainer);
    final screenWidth = tester.binding.window.physicalSize.width / tester.binding.window.devicePixelRatio;
    expect(container.constraints!.maxWidth, (screenWidth - 64) * 0.1);

    await tester.tap(find.byIcon(Icons.favorite).at(1));
    await tester.pumpAndSettle();

    container = tester.widget<AnimatedContainer>(animatedContainer);
    expect(container.constraints!.maxWidth, (screenWidth - 64) * 0.2);
  });
}
