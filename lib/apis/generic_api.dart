import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test_auth_app/utils/db.dart';

Future<void> getNewToken() async {
  final db = await getDatabase();

  final tokens = await db.query('tokens');
  final token = tokens[0]["refresh_token"] as String;

  final headers = {
    'Authorization': 'Bearer $token',
    'content-type': 'application/json',
  };

  final response = await http.get(
    Uri.http('192.168.56.153:3000', 'new-token'),
    headers: headers,
  );

  if (response.statusCode >= 400) {
    await db.update('tokens', {'access_token': '', 'refresh_token': ''});
    throw Exception("Error");
  }

  final Map<String, dynamic> data = json.decode(response.body);
  final accessToken = data['accessToken'];
  //final refreshToken = data['refreshToken'];

  await db.update('tokens', {
    'access_token': accessToken,
    // 'refresh_token': refreshToken,
  });
}

Future<T> get<T>(Uri url, {bool retry = false}) async {
  final db = await getDatabase();

  final tokens = await db.query('tokens');
  final accessToken = tokens[0]["access_token"] as String;

  final headers = {
    'Authorization': 'Bearer $accessToken',
    'content-type': 'application/json',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 401 && !retry) {
    await getNewToken();
    return get<T>(url, retry: true);
  }

  if (response.statusCode >= 400) {
    print(' ===== error ==== ');
    print(response.statusCode);
    print(response.body);
    throw Exception("Error");
  }

  return json.decode(response.body) as T;
}
