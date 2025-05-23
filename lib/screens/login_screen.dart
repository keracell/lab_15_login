import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/providers/locale_notifier.dart';
import 'package:test_auth_app/widgets/custom_number_pad.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _currentLocale = 'az';

  final _secureStorage = FlutterSecureStorage();

  Future<void> _storeCredentials(String username, String password) async {
    await _secureStorage.write(key: 'username', value: username);
    await _secureStorage.write(key: 'password', value: password);
  }

  final _localAuth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return await _localAuth.canCheckBiometrics &&
        await _localAuth.isDeviceSupported();
  }

  Future<bool> authenticateWithBiometrics() async {
    return await _localAuth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometrics', enabled);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      await ref.read(authProvider.notifier).login(_username, _password);
      await _storeCredentials(_username, _password);
      //await authenticateWithBiometrics();
      await setBiometricsEnabled(true);
    } catch (e) {
      print(' ======= error $e');
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('OK'),
              ),
            ],
            title: Text(e.toString()),
          );
        },
      );
    }
  }

  void setLocale(String locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            icon: Icon(Icons.translate),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Localizations.override(
          context: context,
          locale: Locale(_currentLocale),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter your login";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: locale.username),
                    onSaved: (value) {
                      _username = value!;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return "Enter your password";
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: locale.password),
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _submit, child: Text(locale.login)),
                  Container(
                    color: Theme.of(context).colorScheme.secondary,
                    child: CustomNumberPad(
                      maxLength: 5,
                      onFullyEntered: (s) {
                        print('fully entered: $s');
                      },
                      onChanged: (s) {
                        print('changed $s');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
