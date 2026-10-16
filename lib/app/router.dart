import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/outfits/outfits_screen.dart';
import '../features/recommendations/recommendations_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/wardrobe/wardrobe_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import 'app_shell.dart';

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => screen)],
    );

/// Each app instance gets its own router (created in the app's State).
GoRouter createRouter() => GoRouter(
      initialLocation: '/dashboard',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            _branch('/dashboard', const DashboardScreen()),
            _branch('/wardrobe', const WardrobeScreen()),
            _branch('/outfits', const OutfitsScreen()),
            _branch('/recommendations', const RecommendationsScreen()),
            _branch('/wishlist', const WishlistScreen()),
            _branch('/settings', const SettingsScreen()),
          ],
        ),
      ],
    );
