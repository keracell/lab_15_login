import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/widgets/custom_number_pad.dart';

class SecureLoginWidget extends ConsumerStatefulWidget {
  const SecureLoginWidget({super.key});

  @override
  ConsumerState<SecureLoginWidget> createState() => _SecureLoginWidgetState();
}

class _SecureLoginWidgetState extends ConsumerState<SecureLoginWidget> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _enteredPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _isSettingUpPin = false;
  bool _showLoginForm = true;
  bool _useBiometrics = false;
  bool _isBiometricAvailable = false;

  final _secureStorage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkBiometricsAvailability();
    _checkExistingCredentials();
  }

  Future<void> _checkBiometricsAvailability() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    final isSupported = await _localAuth.isDeviceSupported();
    setState(() {
      _isBiometricAvailable = canCheck && isSupported;
    });
  }

  Future<void> _checkExistingCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCredentials = await _secureStorage.containsKey(key: 'nw_username');
    final hasPin = await _secureStorage.containsKey(key: 'nw_userPin');
    final useBio = prefs.getBool('use_biometrics') ?? false;

    setState(() {
      _useBiometrics = useBio;
      if (hasCredentials && hasPin) {
        _showLoginForm = false;
      }
    });
  }

  Future<void> _storeCredentials(String username, String password) async {
    await _secureStorage.write(key: 'nw_username', value: username);
    await _secureStorage.write(key: 'nw_password', value: password);
  }

  Future<bool> authenticateWithBiometrics() async {
    return await _localAuth.authenticate(
      localizedReason: 'Please authenticate to proceed',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<void> _setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometrics', enabled);
    setState(() {
      _useBiometrics = enabled;
    });
  }

  Future<void> _setupPin() async {
    if (_newPin.length == 4 && _newPin == _confirmPin) {
      await _secureStorage.write(key: 'nw_userPin', value: _newPin);
      if (_useBiometrics && _isBiometricAvailable) {
        final authenticated = await authenticateWithBiometrics();
        if (authenticated) {
          await _submitAfterPinSetup();
          return;
        }
      }
      await _submitAfterPinSetup();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match or are not 4 digits')),
      );
    }
  }

  Future<void> _submitAfterPinSetup() async {
    try {
      await ref.read(authProvider.notifier).login(_username, _password);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  Future<void> _verifyPin() async {
    final storedPin = await _secureStorage.read(key: 'nw_userPin');
    if (_enteredPin.length == 4 && _enteredPin == storedPin) {
      if (_useBiometrics && _isBiometricAvailable) {
        final authenticated = await authenticateWithBiometrics();
        if (!authenticated) return;
      }
      _autoLoginWithStoredCredentials();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Incorrect PIN')));
      setState(() {
        _enteredPin = '';
      });
    }
  }

  Future<void> _autoLoginWithStoredCredentials() async {
    try {
      final username = await _secureStorage.read(key: 'nw_username');
      final password = await _secureStorage.read(key: 'nw_password');
      if (username != null && password != null) {
        await ref.read(authProvider.notifier).login(username, password);
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auto-login failed: $e')));
      setState(() {
        _showLoginForm = true;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      // First verify credentials with server
      await ref.read(authProvider.notifier).login(_username, _password);
      await _storeCredentials(_username, _password);
      setState(() {
        _showLoginForm = false;
        _isSettingUpPin = true;
      });
    } catch (e) {
      print('2 $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
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
            decoration: InputDecoration(labelText: 'locale.username'),
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
            decoration: InputDecoration(labelText: 'locale.password'),
            onSaved: (value) {
              _password = value!;
            },
          ),
          const SizedBox(height: 16),
          if (_isBiometricAvailable)
            CheckboxListTile(
              title: Text('Use Biometrics'),
              value: _useBiometrics,
              onChanged: (value) => _setBiometricsEnabled(value ?? false),
            ),
          ElevatedButton(onPressed: _submit, child: Text('locale.login')),
        ],
      ),
    );
  }

  Widget _buildPinSetupScreen(BuildContext context) {
    return Column(
      children: [
        Text(
          _newPin.isEmpty ? 'Create a 4-digit PIN' : 'Confirm your PIN',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final currentPin = _newPin.isEmpty ? _newPin : _confirmPin;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index < currentPin.length
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        CustomNumberPad(
          maxLength: 4,
          onFullyEntered: (pin) {
            print('newPin: $_newPin, confirm: $_confirmPin');
            if (_newPin.isEmpty) {
              setState(() {
                _newPin = pin;
              });
            } else {
              setState(() {
                _confirmPin = pin;
                _setupPin();
              });
            }
          },
          onChanged: (pin) {
            print('changed: $pin');
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _newPin = '';
              _confirmPin = '';
            });
          },
          child: Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildPinEntryScreen(BuildContext context) {
    return Column(
      children: [
        Text('Enter your PIN', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index < _enteredPin.length
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        CustomNumberPad(
          maxLength: 4,
          onFullyEntered: (pin) {
            setState(() {
              _enteredPin = pin;
              _verifyPin();
            });
          },
          onChanged: (pin) {
            setState(() {
              _enteredPin = pin;
            });
          },
        ),
        const SizedBox(height: 16),
        if (_isBiometricAvailable && _useBiometrics)
          IconButton(
            icon: Icon(Icons.fingerprint),
            onPressed: () async {
              final authenticated = await authenticateWithBiometrics();
              if (authenticated) {
                _autoLoginWithStoredCredentials();
              }
            },
          ),
        TextButton(
          onPressed: () {
            setState(() {
              _showLoginForm = true;
            });
          },
          child: Text('Use Password Instead'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_showLoginForm) _buildLoginForm(context),
              if (_isSettingUpPin) _buildPinSetupScreen(context),
              if (!_showLoginForm && !_isSettingUpPin)
                _buildPinEntryScreen(context),
            ],
          ),
        ),
      ),
    );
  }
}
