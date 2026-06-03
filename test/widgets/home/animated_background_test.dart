import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/animated_background.dart';

void main() {
  group('AnimatedBackground', () {
    testWidgets('renders with animation', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(seconds: 1),
      );
      final anim = CurvedAnimation(parent: controller, curve: Curves.linear);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBackground(gradientAnimation: anim),
          ),
        ),
      );

      expect(find.byType(AnimatedBackground), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      controller.dispose();
    });
  });
}
