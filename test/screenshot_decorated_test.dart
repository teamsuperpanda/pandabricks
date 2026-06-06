import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_audio_provider.dart';
import 'widgets/screenshot_decorator.dart';

class _Device {
  const _Device(this.name, this.widthDp, this.heightDp);

  final String name;
  final double widthDp;
  final double heightDp;

  String goldenFolder(String localeTag) => 'golden/$name/$localeTag';
}

const _devices = [
  _Device('iphone_5.5', 414, 736),
  _Device('iphone_6.9', 440, 956),
  _Device('iphone_6.5', 414, 896),
  _Device('android', 360, 640),
];

Widget _buildApp({
  required LocaleProvider localeProvider,
  required MockAudioProvider audioProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
      ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  const targetLocales = [Locale('en')];

  for (final locale in targetLocales) {
    final localeTag = locale.languageCode;
    group(localeTag, () {
      late MockAudioProvider audioProvider;
      late LocaleProvider localeProvider;

      setUp(() {
        audioProvider = MockAudioProvider();
        localeProvider = LocaleProvider(enablePersistence: false);
        localeProvider.setLocale(locale);
      });

      for (final device in _devices) {
        group(device.name, () {
          testWidgets('main_screen', (tester) async {
            addTearDown(() => tester.binding.setSurfaceSize(null));

            final decorator = ScreenshotDecorator(
              deviceWidth: device.widthDp,
              deviceHeight: device.heightDp,
              tagline: 'A modern falling blocks game',
              marketingLine1: 'Classic mode  •  Time Challenge  •  Blitz mode',
              marketingLine2: 'Special bricks  •  13 languages  •  Panda theme',
              child: _buildApp(
                localeProvider: localeProvider,
                audioProvider: audioProvider,
              ),
            );

            await tester.binding.setSurfaceSize(
              Size(decorator.canvasWidth, decorator.canvasHeight),
            );
            await tester.pumpWidget(decorator);
            await tester.pump();

            await expectLater(
              find.byType(ScreenshotDecorator),
              matchesGoldenFile(
                '${device.goldenFolder(localeTag)}/main_screen.png',
              ),
            );
          });
        });
      }
    });
  }
}
