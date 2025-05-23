import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/providers/locale_notifier.dart';
import 'package:test_auth_app/screens/login_screen.dart';
import 'package:test_auth_app/screens/main_screen.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Future<void> _getTokens;

  @override
  void initState() {
    super.initState();
    _getTokens = ref.read(authProvider.notifier).getTokens();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: [Locale('en'), Locale('az')],
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: _getTokens,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // if (!snapshot.hasData) return const Center(child: Text('No Data'));

            if (tokens.accessToken.isEmpty) return const LoginScreen();
            return const MainScreen();
          },
        ),
      ),
    );
  }
}
