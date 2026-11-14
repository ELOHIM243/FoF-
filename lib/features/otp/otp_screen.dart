import 'package:flutter/material.dart';
import '../../core/l10n/l10n_ext.dart';
import '../profile/profile_screen.dart';

class OtpScreen extends StatelessWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(l10n.otpTitle, style: Theme.of(context).textTheme.headlineSmall),
            Text(l10n.otpSubtitle(phone)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen(phone: phone))),
              child: Text(l10n.otpVerify),
            )
          ],
        ),
      ),
    );
  }
}
