import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'home_screen.dart';
import 'info_screen.dart';
import 'watchlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    WatchlistScreen(),
    InfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmarks_outlined),
            selectedIcon: const Icon(Icons.bookmarks_rounded),
            label: l10n.navWatchlist,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline_rounded),
            selectedIcon: const Icon(Icons.info_rounded),
            label: l10n.navInfo,
          ),
        ],
      ),
    );
  }
}
