import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pandabricks/l10n/app_localizations.dart';
import 'package:pandabricks/providers/audio_provider.dart';
import 'package:pandabricks/providers/locale_provider.dart';
import 'package:pandabricks/screens/home/home_screen.dart';
import 'package:pandabricks/screens/game/screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Panda Bricks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Fredoka',
        scaffoldBackgroundColor: const Color(0x00000000),
      ),
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
      routes: {
        '/game': (_) => const GameScreen(),
      },
    );
  }
}
