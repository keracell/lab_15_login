import 'package:test_auth_app/apis/generic_api.dart' as api;
import 'package:test_auth_app/providers/data_notifier.dart';

Future getData() async {
  final data = await api.get<Map<String, dynamic>>(
    Uri.http('192.168.56.153:3000', 'dummy-data'),
  );

  final items =
      data['data']['items']
          .map(
            (item) => DataTypeItem(
              colors: ColorsType.fromMap(item['color']),
              id: item['id'],
              name: item['name'],
              isDefault: item['isDefault'] ?? false,
            ),
          )
          .toList();

  return items;
}

Future getDetails(int id) async {
  final data = await api.get<Map<String, dynamic>>(
    Uri.http('192.168.56.153:3000', 'details/$id'),
  );

  print(data);

  return data;
}
