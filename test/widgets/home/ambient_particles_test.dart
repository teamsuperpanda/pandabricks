import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/ambient_particles.dart';

void main() {
  group('AmbientParticles', () {
    testWidgets('renders particles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientParticles(),
          ),
        ),
      );

      expect(find.byType(AmbientParticles), findsOneWidget);
    });
  });
}
