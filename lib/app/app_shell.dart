import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _destinations = [
  (icon: Icons.dashboard_outlined, label: 'Dashboard'),
  (icon: Icons.checkroom_outlined, label: 'Wardrobe'),
  (icon: Icons.style_outlined, label: 'Outfits'),
  (icon: Icons.auto_awesome_outlined, label: 'Recommendations'),
  (icon: Icons.favorite_border, label: 'Wishlist'),
  (icon: Icons.settings_outlined, label: 'Settings'),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int i) =>
      navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    if (wide) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _select,
            labelType: NavigationRailLabelType.all,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ]),
      );
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}
