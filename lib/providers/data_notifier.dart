import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/apis/data_api.dart' as data_api;

class ColorsType {
  ColorsType({required this.r, required this.g, required this.b});

  ColorsType.fromMap(Map<String, dynamic> colors)
    : r = colors['r'],
      g = colors['g'],
      b = colors['b'];

  final int r;
  final int g;
  final int b;
}

class DataTypeItem {
  DataTypeItem({
    required this.colors,
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final ColorsType colors;
  final bool isDefault;
}

class DataType {
  DataType({required this.items});

  final List<DataTypeItem> items;
}

class MyType {
  MyType({this.data});
  final DataType? data;
}

class DataNotifier extends StateNotifier<List<DataTypeItem>> {
  DataNotifier() : super([]);

  Future<void> getData() async {
    final data = await data_api.getData();

    final List<DataTypeItem> lastData = [];
    for (var i = 0; i < data.length; i++) {
      lastData.add(data[i]);
    }
    state = lastData;
  }
}

final dataProvider = StateNotifierProvider<DataNotifier, dynamic>(
  (ref) => DataNotifier(),
);
