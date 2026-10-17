import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/dashboard_screen.dart';
import '../features/outfits/outfit_builder_screen.dart';
import '../features/outfits/outfits_screen.dart';
import '../features/recommendations/recommendations_screen.dart';
import '../features/settings/preferences_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/wardrobe/clothing_form_screen.dart';
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/wardrobe',
              builder: (context, state) => const WardrobeScreen(),
              routes: [
                // Static segments must be declared before ':id' routes.
                GoRoute(
                  path: 'archived',
                  builder: (context, state) =>
                      const WardrobeScreen(archived: true),
                ),
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const ClothingFormScreen(),
                ),
                GoRoute(
                  path: 'item/:id',
                  builder: (context, state) =>
                      ClothingFormScreen(itemId: state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/outfits',
              builder: (context, state) => const OutfitsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const OutfitBuilderScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      OutfitBuilderScreen(outfitId: state.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        _branch('/recommendations', const RecommendationsScreen()),
        _branch('/wishlist', const WishlistScreen()),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'preferences',
                  builder: (context, state) => const PreferencesScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
