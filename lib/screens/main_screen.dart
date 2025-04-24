import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/providers/data_notifier.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late Future _getData;

  void _logout() async {
    ref.read(authProvider.notifier).logout();
  }

  @override
  void initState() {
    super.initState();
    _getData = ref.read(dataProvider.notifier).getData();
  }

  void _refresh() {
    ref.read(dataProvider.notifier).getData();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final data = ref.watch(dataProvider);
    print(" ===== build data ===== ");
    print(data);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.main),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.exit_to_app)),
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _getData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            print(" ===== snapshot ===== ");
            print(data);

            return Center(child: Text(locale.future));
          },
        ),
      ),
    );
  }
}
