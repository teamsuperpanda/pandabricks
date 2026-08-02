import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/dialogs/game/custom_game_dialog.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:provider/provider.dart';

import 'mocks/mock_audio_provider.dart';

Widget localizedApp({required Locale locale, required Widget home}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('game labels align to the leading edge in RTL', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ChangeNotifierProvider<AudioProvider>.value(
        value: MockAudioProvider(),
        child: localizedApp(
          locale: const Locale('ar'),
          home: const GameScreen(),
        ),
      ),
    );
    await tester.pump();

    final nextLabelAlign = tester.widget<Align>(
      find.ancestor(
        of: find.text('التالي'),
        matching: find.byType(Align),
      ),
    );

    expect(nextLabelAlign.alignment, AlignmentDirectional.centerStart);
    expect(
      nextLabelAlign.alignment.resolve(TextDirection.rtl),
      Alignment.centerRight,
    );
  });

  testWidgets('custom board option spacing follows the trailing edge', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      localizedApp(
        locale: const Locale('ar'),
        home: const Scaffold(body: CustomGameDialog()),
      ),
    );

    final optionPadding = find
        .ancestor(of: find.text('8'), matching: find.byType(Padding))
        .evaluate()
        .map((element) => (element.widget as Padding).padding)
        .whereType<EdgeInsetsDirectional>()
        .single;

    expect(
      optionPadding.resolve(TextDirection.ltr),
      const EdgeInsets.only(right: 8),
    );
    expect(
      optionPadding.resolve(TextDirection.rtl),
      const EdgeInsets.only(left: 8),
    );
  });
}
