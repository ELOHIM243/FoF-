
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _redirectUrl =
      'com.elohim243.fof://login-callback/';

  bool _isLogin = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Remplis tous les champs.');
      return;
    }

    if (password.length < 6) {
      _showMessage(
        'Le mot de passe doit contenir au moins 6 caractères.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (mounted) {
          _showMessage('Connexion réussie !');
        }
      } else {
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (mounted) {
          _showMessage(
            response.session == null
                ? 'Compte créé ! Vérifie ta boîte e-mail.'
                : 'Compte créé avec succès !',
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) {
        _showMessage('Une erreur est survenue. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Impossible de lancer la connexion Google. Vérifie Internet et réessaie.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),

                const Text(
                  'FOF',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Connecte-toi à ton compte'
                      : 'Crée ton compte FOF',
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || _isGoogleLoading
                            ? null
                            : _authenticate,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _isLogin
                                ? 'Se connecter'
                                : 'Créer un compte',
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OU'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isLoading || _isGoogleLoading
                            ? null
                            : _signInWithGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.g_mobiledata,
                            size: 30,
                          ),
                    label: const Text(
                      'Continuer avec Google',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed:
                      _isLoading || _isGoogleLoading
                          ? null
                          : () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                  child: Text(
                    _isLogin
                        ? 'Pas encore de compte ? Inscris-toi'
                        : 'Déjà un compte ? Connecte-toi',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
