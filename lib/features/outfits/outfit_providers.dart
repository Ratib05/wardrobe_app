import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import 'outfit_repository.dart';

final outfitRepositoryProvider = Provider<OutfitRepository>(
  (ref) => OutfitRepository(ref.watch(appDatabaseProvider)),
);

final outfitsProvider = StreamProvider<List<OutfitWithItems>>(
  (ref) => ref.watch(outfitRepositoryProvider).watchAll(),
);
