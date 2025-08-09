import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pandabricks/home_page.dart';

void main() {
  testWidgets('HomePage displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomePage(),
    ));

    // Check for title
    expect(find.text('Pandabricks'), findsOneWidget);
    
    // Check for version subtitle
    expect(find.text('v2.0 • The Ultimate Refresh'), findsOneWidget);
    
    // Check mode cards per old layout
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Bamboo Blitz'), findsOneWidget);
    
    // Check for mode descriptions
    expect(find.text('Relaxed play with a gentle pace.'), findsOneWidget);
    expect(find.text('Classic challenge. Balanced and fun.'), findsOneWidget);
    expect(find.text('Beat the clock with spicy specials.'), findsOneWidget);
    
    // Check top icons
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsOneWidget);
    expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    
    // Check audio toggles
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('SFX'), findsOneWidget);
  });
}