import 'package:flutter/material.dart';
import 'package:immolink_mobile/models/Currency.dart';
import 'package:immolink_mobile/views/screens/account_screen.dart';
import 'package:immolink_mobile/views/screens/chat_screen.dart';
import 'package:immolink_mobile/views/screens/home_content_screen.dart';
import 'package:immolink_mobile/views/screens/map_screen.dart';
import 'package:immolink_mobile/views/widgets/default_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex  = 0;
  final List<Currency> currencies = [
    Currency(
      code: 'MRU',
      name: 'Mauritania Ouguiya',
      imageUrl: 'assets/flags/mauritania.png',
      exchangeRate: 1.0,
      symbol: 'UM',
    ),
    Currency(
      code: 'EUR',
      name: 'Euro',
      imageUrl: 'assets/flags/europe.png',
      exchangeRate: 0.82,
      symbol: '€',
    ),
    Currency(
      code: 'USD',
      name: 'US Dollar',
      imageUrl: 'assets/flags/usd.png',
      exchangeRate: 1.0,
      symbol: '\$',
    ),
  ];

  final List<Widget> _screens = [
    const HomeContentScreen(),
    const AccountScreen(),
     MapScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        elevation: 16.0,
      ),
      body:_screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, //New
        onTap: _onTap,

        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
        ],
      ),
      appBar:  const DefaultAppBar(),
      );
  }
}

