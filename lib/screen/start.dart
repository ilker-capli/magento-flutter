import 'package:flutter/material.dart';
import 'package:magento_flutter/screen/elastic.dart';
import 'package:magento_flutter/tabs/elastic.dart';
import 'package:magento_flutter/tabs/search.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';
import '../tabs/accounts.dart';
import '../tabs/cart.dart';
import '../tabs/home.dart';
import '../utils.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateScreenState();
}

class _StateScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeTabs(),
    ElasticTabs(),
    SearchTabs(),
    AccountsTabs(),
    CartTabs(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.id.isEmpty) {
      getCart(context).then((value) {
        if (value.isNotEmpty) {
          context.read<CartProvider>().setId(value);
        }
      });
    }
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Anasayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: "Elastic",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Hesabım",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Sepetim",
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}
