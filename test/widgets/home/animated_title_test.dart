import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/widgets/home/animated_title.dart';
import 'package:provider/provider.dart';

void main() {
  group('AnimatedTitle', () {
    testWidgets('displays app title', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(seconds: 1),
      );
      final anim = CurvedAnimation(parent: controller, curve: Curves.linear);

      await tester.pumpWidget(
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) =>         LocaleProvider(enablePersistence: false),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: AnimatedTitle(floatingAnimation: anim),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(AnimatedTitle), findsOneWidget);

      controller.dispose();
    });
  });
}
