import 'package:flutter/material.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_theme.dart';
import '../otp/otp_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble, size: 80, color: AppColors.primary),
            const SizedBox(height: 20),
            Text(l10n.onboardingTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 40),
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(labelText: l10n.onboardingPhoneLabel, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phone: _ctrl.text))),
              child: Text(l10n.onboardingContinue),
            )
          ],
        ),
      ),
    );
  }
}