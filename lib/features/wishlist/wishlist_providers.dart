import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/wardrobe_values.dart';
import '../../database/app_database.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clothingRepositoryProvider),
  ),
);

final wishlistProvider =
    StreamProvider.family<List<WishlistItem>, WishlistStatus>(
      (ref, status) => ref.watch(wishlistRepositoryProvider).watch(status),
    );
