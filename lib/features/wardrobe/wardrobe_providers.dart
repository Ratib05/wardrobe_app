import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'clothing_repository.dart';

final clothingRepositoryProvider = Provider<ClothingRepository>(
  (ref) => ClothingRepository(ref.watch(appDatabaseProvider)),
);

final activeItemCountProvider = StreamProvider<int>(
  (ref) => ref.watch(clothingRepositoryProvider).watchActiveCount(),
);
