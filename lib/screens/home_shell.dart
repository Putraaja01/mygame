import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import 'akun_screen.dart';
import 'beranda_screen.dart';
import 'shop_screen.dart';

/// Kerangka utama dengan navigasi bawah: Beranda, Shop, dan Akun.
class HomeShell extends StatefulWidget {
  final LibraryRepository repo;
  const HomeShell({super.key, required this.repo});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BerandaScreen(repo: widget.repo),
      const ShopScreen(),
      AkunScreen(repo: widget.repo),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
