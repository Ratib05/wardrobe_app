import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/clothing_item.dart';
import 'clothing_repository.dart';
import 'wardrobe_filter.dart';

final clothingRepositoryProvider = Provider<ClothingRepository>(
  (ref) => ClothingRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(imageStorageProvider),
  ),
);

final activeItemCountProvider = StreamProvider<int>(
  (ref) => ref.watch(clothingRepositoryProvider).watchActiveCount(),
);

/// Family key: whether to show archived items.
final wardrobeItemsProvider = StreamProvider.family<List<ClothingItem>, bool>(
  (ref, archived) =>
      ref.watch(clothingRepositoryProvider).watchItems(archived: archived),
);

class WardrobeFilterNotifier extends Notifier<WardrobeFilter> {
  @override
  WardrobeFilter build() => const WardrobeFilter();

  void set(WardrobeFilter filter) => state = filter;

  /// Clears search and facets but keeps the chosen sort order.
  void clear() => state = WardrobeFilter(sort: state.sort);
}

final wardrobeFilterProvider =
    NotifierProvider<WardrobeFilterNotifier, WardrobeFilter>(
      WardrobeFilterNotifier.new,
    );

final filteredWardrobeProvider =
    Provider.family<AsyncValue<List<ClothingItem>>, bool>((ref, archived) {
      final filter = ref.watch(wardrobeFilterProvider);
      return ref.watch(wardrobeItemsProvider(archived)).whenData(filter.apply);
    });

/// Photo count and missing-photo count; refreshes when the wardrobe changes.
final photoStatusProvider = FutureProvider<({int total, int missing})>((
  ref,
) async {
  ref.watch(wardrobeItemsProvider(false));
  ref.watch(wardrobeItemsProvider(true));
  return ref.read(clothingRepositoryProvider).photoStatus();
});
