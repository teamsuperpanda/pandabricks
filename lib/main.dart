import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Preserve the splash screen
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  double? _cachedShortestSide;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _removeSplashScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateOrientation();
  }

  void _removeSplashScreen() async {
    // Wait for 1 second before removing the splash screen
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  void _updateOrientation() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    // Only update orientation if screen size has changed significantly
    if (_cachedShortestSide == null || (_cachedShortestSide! - shortestSide).abs() > 50) {
      _cachedShortestSide = shortestSide;
      if (shortestSide < 600) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    }
  }

  @override
  void dispose() {
    context.read<AudioProvider>().dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AudioProvider>().stopMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    // Update orientation on first build or when context changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOrientation();
    });

    // Apply font family fallback for missing glyph coverage (e.g. use NotoSans when available)
    TextTheme applyFallback(TextTheme base) {
      const fallback = <String>[];
      TextStyle? applyFallback(TextStyle? s) => s?.copyWith(fontFamilyFallback: fallback);
      return TextTheme(
        displayLarge: applyFallback(base.displayLarge),
        displayMedium: applyFallback(base.displayMedium),
        displaySmall: applyFallback(base.displaySmall),
        headlineLarge: applyFallback(base.headlineLarge),
        headlineMedium: applyFallback(base.headlineMedium),
        headlineSmall: applyFallback(base.headlineSmall),
        titleLarge: applyFallback(base.titleLarge),
        titleMedium: applyFallback(base.titleMedium),
        titleSmall: applyFallback(base.titleSmall),
        bodyLarge: applyFallback(base.bodyLarge),
        bodyMedium: applyFallback(base.bodyMedium),
        bodySmall: applyFallback(base.bodySmall),
        labelLarge: applyFallback(base.labelLarge),
        labelMedium: applyFallback(base.labelMedium),
        labelSmall: applyFallback(base.labelSmall),
      );
    }

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Panda Bricks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Fredoka',
        // Ensure text styles will fall back to NotoSans if glyphs are missing
        textTheme: applyFallback(ThemeData.light().textTheme),
      ),
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
      routes: {
        '/game': (_) => const GameScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
