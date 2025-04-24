import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/apis/data_api.dart' as dataApi;

class DataNotifier extends StateNotifier<dynamic> {
  DataNotifier() : super({});

  Future<void> getData() async {
    final data = await dataApi.getData();
    print(' ===== get data ===== ');
    print(data);
    state = data;
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, dynamic>(
  (ref) => DataNotifier(),
);
