import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/chats/chats_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';

class FofApp extends StatelessWidget {
  const FofApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: state.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: state.themeMode,
      home: state.isLoggedIn ? const ChatsScreen() : const OnboardingScreen(),
    );
  }
}
