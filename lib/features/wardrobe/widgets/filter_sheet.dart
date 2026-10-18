import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/enum_chips.dart';
import '../../../core/wardrobe_values.dart';
import '../wardrobe_filter.dart';
import '../wardrobe_providers.dart';

/// Bottom sheet that edits the shared [wardrobeFilterProvider] live.
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(wardrobeFilterProvider);
    final notifier = ref.read(wardrobeFilterProvider.notifier);
    Widget section(String title, Widget chips) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          chips,
        ],
      ),
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Row(
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: notifier.clear, child: const Text('Clear')),
            ],
          ),
          section(
            'Sort by',
            DropdownButton<WardrobeSort>(
              value: f.sort,
              items: [
                for (final s in WardrobeSort.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (s) => notifier.set(f.copyWith(sort: s)),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Favourites only'),
            value: f.favouritesOnly,
            onChanged: (v) => notifier.set(f.copyWith(favouritesOnly: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Needs details'),
            subtitle: const Text('No main colour or formality yet'),
            value: f.needsDetailsOnly,
            onChanged: (v) => notifier.set(f.copyWith(needsDetailsOnly: v)),
          ),
          section(
            'Category',
            EnumChips<ClothingCategory>(
              values: ClothingCategory.values,
              label: (v) => v.label,
              selected: f.categories,
              onChanged: (s) => notifier.set(f.copyWith(categories: s)),
            ),
          ),
          section(
            'Colour',
            EnumChips<WardrobeColour>(
              values: WardrobeColour.values,
              label: (v) => v.label,
              selected: f.colours,
              onChanged: (s) => notifier.set(f.copyWith(colours: s)),
            ),
          ),
          section(
            'Style',
            EnumChips<StyleTag>(
              values: StyleTag.values,
              label: (v) => v.label,
              selected: f.styles,
              onChanged: (s) => notifier.set(f.copyWith(styles: s)),
            ),
          ),
          section(
            'Season',
            EnumChips<Season>(
              values: Season.values,
              label: (v) => v.label,
              selected: f.seasons,
              onChanged: (s) => notifier.set(f.copyWith(seasons: s)),
            ),
          ),
          section(
            'Occasion',
            EnumChips<Occasion>(
              values: Occasion.values,
              label: (v) => v.label,
              selected: f.occasions,
              onChanged: (s) => notifier.set(f.copyWith(occasions: s)),
            ),
          ),
          section(
            'Formality',
            EnumChips<Formality>(
              values: Formality.values,
              label: (v) => v.label,
              selected: f.formalities,
              onChanged: (s) => notifier.set(f.copyWith(formalities: s)),
            ),
          ),
        ],
      ),
    );
  }
}
