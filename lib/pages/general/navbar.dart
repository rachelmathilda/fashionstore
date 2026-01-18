import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../catalog/catalog_screen.dart';
import '../bag/bag_screen.dart';
import '../profile/profile_screen.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final List<Map<String, dynamic>> _pages = [
    {'page': HomeScreen(), 'title': 'Home'},
    {'page': CatalogScreen(), 'title': 'Search'},
    {'page': BagScreen(), 'title': 'Bag'},
    {'page': ProfileScreen(), 'title': 'Profile'},
  ];

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title']),
        elevation: 0,
      ),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              onTap: _selectPage,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              currentIndex: _selectedPageIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 40),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 40),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag, size: 40),
                  label: 'Bag',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 40),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
