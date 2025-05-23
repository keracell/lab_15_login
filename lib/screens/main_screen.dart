import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_auth_app/l10n/app_localizations.dart';
import 'package:test_auth_app/providers/auth_notifier.dart';
import 'package:test_auth_app/providers/data_notifier.dart';
import 'package:test_auth_app/apis/data_api.dart' as data_api;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:test_auth_app/widgets/chart_sample.dart';
import 'package:test_auth_app/widgets/login_widget.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80',
];

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late Future<void> _getData;
  Map<String, dynamic>? _details;
  final SwiperController _swiperController = SwiperController();
  int _currentIndex = 0;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    print('index = $index');
    if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (ctx) => SecureLoginWidget()));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    ref.read(authProvider.notifier).logout();
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    await ref.read(dataProvider.notifier).getData();
    final items = ref.read(dataProvider) as List<DataTypeItem>;

    final item = items[0];
    _changeIndex(item, 0);
  }

  void _changeIndex(DataTypeItem item, int index) async {
    print('change = $index');
    final data = await data_api.getDetails(item.id);

    setState(() {
      _details = data;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final items = ref.watch(dataProvider) as List<DataTypeItem>;

    Widget currentWidget = Center(child: Text('default'));

    if (_selectedIndex == 0) {
      currentWidget = Center(
        child:
            (items == null)
                ? Text('loading')
                : Column(
                  children: [
                    Center(child: Text(locale.future)),
                    SizedBox(height: 16),
                    if (_details != null) Text(_details!['rand']),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      height: 100,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: false,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                        ),
                        items:
                            items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Card(
                                // elevation: 4,
                                color: Color.fromARGB(
                                  255,
                                  item.colors.r,
                                  item.colors.g,
                                  item.colors.b,
                                ),
                                child:
                                    index == _currentIndex
                                        ? Text(item.name)
                                        : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$_currentIndex $index ${item.name}',
                                            ),
                                          ],
                                        ),
                              );
                            }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      height: 100,
                      child: Swiper(
                        controller: _swiperController,
                        // index: defaultIndex < 0 ? 0 : defaultIndex,
                        viewportFraction: 0.8,
                        scale: 0.8,
                        layout: SwiperLayout.TINDER,
                        itemWidth: 300,
                        itemHeight: 100,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            // elevation: 4,
                            color: Color.fromARGB(
                              255,
                              item.colors.r,
                              item.colors.g,
                              item.colors.b,
                            ),
                            child:
                                index == _currentIndex
                                    ? Text(item.name)
                                    : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$_currentIndex $index ${item.name}',
                                        ),
                                      ],
                                    ),
                          );
                        },
                        onIndexChanged: (index) {
                          _changeIndex(items[index], index);
                        },
                      ),
                    ),
                  ],
                ),
      );
    } else if (_selectedIndex == 1) {
      currentWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: LineChartSample2(),
      );
    } else if (_selectedIndex == 3) {
      currentWidget = SecureLoginWidget();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.main),
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.exit_to_app)),
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh)),
        ],
      ),
      body: currentWidget,

      floatingActionButton: FloatingActionButton(
        elevation: 4,
        isExtended: false,
        onPressed: () {
          setState(() {
            _selectedIndex = 2; // middle button
          });
        },
        backgroundColor: Colors.green,
        child: Text('test'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(icon: Icons.home, index: 0, label: 'Əsas'),
              _buildNavItem(icon: Icons.store, index: 1, label: 'Məhsullar'),
              const SizedBox(width: 48), // space for FAB
              _buildNavItem(icon: Icons.map, index: 3, label: 'Filiallar'),
              _buildNavItem(icon: Icons.person, index: 4, label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.green : Colors.white),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
