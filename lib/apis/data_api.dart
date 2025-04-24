import 'package:test_auth_app/apis/generic_api.dart' as api;

Future getData() async {
  print(' ====== before call ====== ');
  final Map<String, dynamic> data = await api.get<Map<String, dynamic>>(
    Uri.http('192.168.56.153:3000', 'dummy-data'),
  );
  print(' ====== data ===== ');
  print(data);
  return data;
}
