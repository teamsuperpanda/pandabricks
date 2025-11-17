import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    late LocaleProvider provider;

    setUp(() {
      provider = LocaleProvider(enablePersistence: false);
    });

    test('initializes with null locale (system default)', () {
      expect(provider.locale, isNull);
    });

    test('setLocale changes current locale', () {
      provider.setLocale(const Locale('es'));
      expect(provider.locale, const Locale('es'));
    });

    test('setLocale notifies listeners', () {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setLocale(const Locale('fr'));
      expect(notified, isTrue);
    });

    test('setLocale with null resets to system default', () {
      provider.setLocale(const Locale('ja'));
      expect(provider.locale, const Locale('ja'));
      
      provider.setLocale(null);
      expect(provider.locale, isNull);
    });

    test('multiple setLocale calls update correctly', () {
      provider.setLocale(const Locale('de'));
      expect(provider.locale, const Locale('de'));
      
      provider.setLocale(const Locale('it'));
      expect(provider.locale, const Locale('it'));
      
      provider.setLocale(const Locale('ko'));
      expect(provider.locale, const Locale('ko'));
    });

    test('setLocale with same locale does not notify', () {
      provider.setLocale(const Locale('en'));
      
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setLocale(const Locale('en'));
      expect(notifyCount, 0);
    });

    test('setLocale with different locale notifies', () {
      provider.setLocale(const Locale('en'));
      
      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      provider.setLocale(const Locale('es'));
      expect(notifyCount, 1);
    });

    testWidgets('LocaleProvider can be used with Provider', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final localeProvider = context.watch<LocaleProvider>();
                return Text('${localeProvider.locale}');
              },
            ),
          ),
        ),
      );

      expect(find.text('null'), findsOneWidget);
    });

    testWidgets('changing locale updates UI', (WidgetTester tester) async {
      final testProvider = LocaleProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: testProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final localeProvider = context.watch<LocaleProvider>();
                return Text('${localeProvider.locale}');
              },
            ),
          ),
        ),
      );

      expect(find.text('null'), findsOneWidget);

      testProvider.setLocale(const Locale('zh'));
      await tester.pump();

      expect(find.text('zh'), findsOneWidget);
    });
  });
}

