import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/navigation/app_router.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/services/logging.dart';
import 'package:pandabricks/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    logError('main', e);
  }
  final musicEnabled = prefs?.getBool('musicEnabled') ?? true;
  final sfxEnabled = prefs?.getBool('sfxEnabled') ?? true;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AudioProvider(musicEnabled: musicEnabled, sfxEnabled: sfxEnabled),
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const _defaultTitle = 'Panda Bricks';
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 1), FlutterNativeSplash.remove);
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  }

  @override
  void dispose() {
    _appRouter.router.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = context.read<AudioProvider>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(audio.stopMusic());
    } else if (state == AppLifecycleState.resumed) {
      if (audio.musicEnabled) {
        unawaited(audio.resumeMusic());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp.router(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? _defaultTitle,
          routerConfig: _appRouter.router,
          theme: AppTheme.dark,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
