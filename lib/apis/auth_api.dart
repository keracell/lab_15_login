import 'dart:convert';

import 'package:test_auth_app/models/tokens_model.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  Future<TokensModel> login(String username, String password) async {
    final url = Uri.http('192.168.56.153:3000', 'login');
    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: json.encode({'login': username, 'password': password}),
    );

    final Map<String, dynamic> data = json.decode(response.body);

    final accessToken = data["accessToken"];
    final refreshToken = data["refreshToken"];

    return TokensModel(accessToken: accessToken, refreshToken: refreshToken);
  }
}
