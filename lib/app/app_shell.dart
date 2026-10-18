import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/backup_history.dart';
import 'providers.dart';
import 'theme.dart';

/// The five main destinations, in branch order. [short] is the label used in
/// the narrow bottom bar.
const _destinations = [
  (icon: Icons.checkroom_outlined, label: 'Wardrobe', short: 'Wardrobe'),
  (icon: Icons.layers_outlined, label: 'Outfits', short: 'Outfits'),
  (icon: Icons.sort, label: 'Suggestions', short: 'Suggest'),
  (icon: Icons.add_box_outlined, label: 'Gaps & wishlist', short: 'Gaps'),
  (icon: Icons.archive_outlined, label: 'Backup', short: 'Backup'),
];

/// Branch index of the Settings page (reached from the sidebar link).
const settingsBranchIndex = 5;

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _select(int i) => navigationShell.goBranch(
    i,
    initialLocation: i == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    if (MediaQuery.sizeOf(context).width >= 600) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(selected: index, onSelect: _select),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        // Settings lives under Backup on narrow screens.
        selectedIndex: index == settingsBranchIndex ? 4 : index,
        onDestinationSelected: _select,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), label: d.short),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(backupHistoryProvider);
    final footer = history.maybeWhen(
      data: (records) => lastBackupLabel(records, DateTime.now()),
      orElse: () => '',
    );
    return Container(
      key: const Key('sidebar'),
      width: 220,
      color: AppColors.sidebar,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
            child: Row(
              children: [
                const Icon(Icons.checkroom, size: 26),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Drobe',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _destinations.length; i++)
            _NavItem(
              icon: _destinations[i].icon,
              label: _destinations[i].label,
              selected: selected == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            selected: selected == settingsBranchIndex,
            onTap: () => onSelect(settingsBranchIndex),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F1EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STORED ON THIS DEVICE', style: monoCaption(context)),
                if (footer.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(footer, key: const Key('last-backup')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: Key('nav-$label'),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.text),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
