import 'package:flutter/material.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/providers/locale_notifier.dart';

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await ref.read(authProvider.notifier).login(_username, _password);
  }

  void setLocale(String locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    print(_currentLocale);

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
