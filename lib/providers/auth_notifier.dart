import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/apis/auth_api.dart';
import 'package:test_auth_app/models/tokens_model.dart';
import 'package:test_auth_app/utils/db.dart';

final authApi = AuthApi();

class AuthNotifier extends StateNotifier<TokensModel> {
  AuthNotifier() : super(TokensModel(accessToken: '', refreshToken: ''));

  Future<void> getTokens() async {
    final db = await getDatabase();
    final data = await db.query('tokens');

    final accessToken = data[0]["access_token"] as String;
    final refreshToken = data[0]["refresh_token"] as String;

    state = TokensModel(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> setAccessToken(accessToken) async {
    final db = await getDatabase();
    await db.update('tokens', {'access_token': accessToken});

    getTokens();
  }

  Future<void> setRefreshToken(refreshToken) async {
    final db = await getDatabase();
    await db.update('tokens', {'refresh_token': refreshToken});

    getTokens();
  }

  Future<void> setTokens(TokensModel tokens) async {
    final db = await getDatabase();
    await db.update('tokens', {
      'refresh_token': tokens.refreshToken,
      'access_token': tokens.accessToken,
    });
    getTokens();
  }

  Future<void> login(String username, String password) async {
    final tokens = await authApi.login(username, password);
    setTokens(tokens);
  }

  Future<void> logout() async {
    setTokens(TokensModel(accessToken: '', refreshToken: ''));
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, TokensModel>(
  (ref) => AuthNotifier(),
);
