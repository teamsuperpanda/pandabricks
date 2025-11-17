import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/providers/locale_provider.dart';

void main() {
  group('LocaleProvider', () {
    late LocaleProvider localeProvider;

    setUp(() {
      localeProvider = LocaleProvider(enablePersistence: false);
    });

    test('should initialize with null locale', () {
      expect(localeProvider.locale, isNull);
    });

    test('should set locale to a specific value', () {
      const locale = Locale('en', 'US');
      localeProvider.setLocale(locale);

      expect(localeProvider.locale, equals(locale));
    });

    test('should set locale to null', () {
      // First set a locale
      const locale = Locale('fr', 'FR');
      localeProvider.setLocale(locale);
      expect(localeProvider.locale, equals(locale));

      // Then set it back to null
      localeProvider.setLocale(null);
      expect(localeProvider.locale, isNull);
    });

    test('should notify listeners when locale changes', () {
      bool notified = false;
      localeProvider.addListener(() {
        notified = true;
      });

      localeProvider.setLocale(const Locale('es', 'ES'));
      expect(notified, isTrue);
    });

    test('should notify listeners when locale is set to null', () {
      // First set a locale to establish a baseline
      localeProvider.setLocale(const Locale('de', 'DE'));

      bool notified = false;
      localeProvider.addListener(() {
        notified = true;
      });

      localeProvider.setLocale(null);
      expect(notified, isTrue);
    });

    test('should not notify listeners when setting the same locale', () {
      const locale = Locale('ja', 'JP');
      localeProvider.setLocale(locale);

      bool notified = false;
      localeProvider.addListener(() {
        notified = true;
      });

      // Set the same locale again
      localeProvider.setLocale(locale);
      expect(notified, isFalse);
    });

    test('should handle different locale variations', () {
      // Test language only
      const english = Locale('en');
      localeProvider.setLocale(english);
      expect(localeProvider.locale, equals(english));

      // Test language with country
      const britishEnglish = Locale('en', 'GB');
      localeProvider.setLocale(britishEnglish);
      expect(localeProvider.locale, equals(britishEnglish));

      // Test different language
      const spanish = Locale('es');
      localeProvider.setLocale(spanish);
      expect(localeProvider.locale, equals(spanish));

      // Test language with script
      const simplifiedChinese = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      localeProvider.setLocale(simplifiedChinese);
      expect(localeProvider.locale, equals(simplifiedChinese));
    });

    test('should support multiple listeners', () {
      int notificationCount = 0;
      void listener() => notificationCount++;

      localeProvider.addListener(listener);
      localeProvider.addListener(listener);
      localeProvider.addListener(listener);

      localeProvider.setLocale(const Locale('ko', 'KR'));
      expect(notificationCount, 3);
    });

    test('should handle rapid locale changes', () {
      const locales = [
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        null,
        Locale('it'),
      ];

      int notificationCount = 0;
      localeProvider.addListener(() => notificationCount++);

      for (final locale in locales) {
        localeProvider.setLocale(locale);
      }

      expect(notificationCount, locales.length);
      expect(localeProvider.locale, equals(locales.last));
    });

    test('should properly dispose without errors', () {
      final provider = LocaleProvider();
      // Should not throw any errors
      expect(() => provider.dispose(), returnsNormally);
    });

    group('Supported locales from app', () {
      // These should match the locales defined in l10n.yaml or supported by the app
      const supportedLocales = [
        Locale('en'), // English
        Locale('ar'), // Arabic
        Locale('bn'), // Bengali
        Locale('de'), // German
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('hi'), // Hindi
        Locale('it'), // Italian
        Locale('ja'), // Japanese
        Locale('ko'), // Korean
        Locale('ru'), // Russian
        Locale('ur'), // Urdu
        Locale('zh'), // Chinese
      ];

      test('should support all app locales', () {
        for (final locale in supportedLocales) {
          localeProvider.setLocale(locale);
          expect(localeProvider.locale, equals(locale),
              reason: 'Failed to set locale: $locale');
        }
      });

      test('should handle locale switching between supported languages', () {
        // Simulate user switching between different languages
        localeProvider.setLocale(supportedLocales[0]); // English
        expect(localeProvider.locale?.languageCode, equals('en'));

        localeProvider.setLocale(supportedLocales[3]); // German
        expect(localeProvider.locale?.languageCode, equals('de'));

        localeProvider.setLocale(supportedLocales[6]); // Hindi
        expect(localeProvider.locale?.languageCode, equals('hi'));

        localeProvider.setLocale(supportedLocales[10]); // Russian
        expect(localeProvider.locale?.languageCode, equals('ru'));
      });
    });

    group('Edge cases', () {
      test('should handle locale with only country code', () {
        // Unusual but should be handled
        const countryOnly = Locale.fromSubtags(countryCode: 'US');
        localeProvider.setLocale(countryOnly);
        expect(localeProvider.locale, equals(countryOnly));
      });

      test('should handle complex locale subtags', () {
        const complexLocale = Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        );
        localeProvider.setLocale(complexLocale);
        expect(localeProvider.locale, equals(complexLocale));
      });
    });
  });
}