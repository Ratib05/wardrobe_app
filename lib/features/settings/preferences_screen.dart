import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/enum_chips.dart';
import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import '../recommendations/recommendations_providers.dart';

/// Explicit likes and dislikes that feed recommendations.
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final repo = ref.read(recommendationRepositoryProvider);

    // Applies the difference between the old and new selection.
    void apply<T extends Enum>(
      PreferenceType type,
      Set<T> before,
      Set<T> after,
    ) {
      for (final v in after.difference(before)) {
        repo.setPreference(type, v.name, true);
      }
      for (final v in before.difference(after)) {
        repo.setPreference(type, v.name, false);
      }
    }

    Widget section<T extends Enum>(
      String key,
      String title,
      List<T> values,
      Set<T> selected,
      PreferenceType type,
    ) => Padding(
      key: Key(key),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          EnumChips<T>(
            values: values,
            label: (v) => (v as dynamic).label as String,
            selected: selected,
            onChanged: (after) => apply(type, selected, after),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendation preferences')),
      body: prefs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(e),
        data: (p) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  section<WardrobeColour>(
                    'preferred-colours',
                    'Preferred colours',
                    WardrobeColour.values,
                    p.preferredColours,
                    PreferenceType.preferredColour,
                  ),
                  section<StyleTag>(
                    'preferred-styles',
                    'Preferred styles',
                    StyleTag.values,
                    p.preferredStyles,
                    PreferenceType.preferredStyle,
                  ),
                  section<Formality>(
                    'preferred-formality',
                    'Preferred formality',
                    Formality.values,
                    p.preferredFormalities,
                    PreferenceType.preferredFormality,
                  ),
                  section<WardrobeColour>(
                    'avoid-colours',
                    'Avoid colours',
                    WardrobeColour.values,
                    p.excludedColours,
                    PreferenceType.excludedColour,
                  ),
                  section<StyleTag>(
                    'avoid-styles',
                    'Avoid styles',
                    StyleTag.values,
                    p.excludedStyles,
                    PreferenceType.excludedStyle,
                  ),
                  SwitchListTile(
                    key: const Key('avoid-one-colour'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Avoid one-colour outfits'),
                    subtitle: const Text(
                      'Hide suggestions where the top and bottom are the '
                      'same or a similar colour.',
                    ),
                    value: p.avoidOneColour,
                    onChanged: repo.setAvoidOneColour,
                  ),
                  Text(
                    'Avoided colours and styles are never recommended.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
