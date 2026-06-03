import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/widgets/home/audio_setting_row.dart';

void main() {
  group('AudioSettingRow', () {
    testWidgets('displays title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AudioSettingRow(
                title: 'Music',
                icon: Icons.music_note,
                initialValue: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Music'), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows volume off icon when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AudioSettingRow(
                title: 'SFX',
                icon: Icons.volume_up,
                initialValue: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);
    });

    testWidgets('calls onChanged when tapped', (WidgetTester tester) async {
      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AudioSettingRow(
                title: 'Music',
                icon: Icons.music_note,
                initialValue: true,
                onChanged: (v) => toggled = v,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.music_note));
      expect(toggled, isFalse);
    });
  });
}
