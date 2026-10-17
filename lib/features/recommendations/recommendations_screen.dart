import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/error_view.dart';
import '../../core/wardrobe_values.dart';
import 'engine/recommendation_engine.dart';
import 'recommendations_providers.dart';
import 'widgets/recommendation_card.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  Occasion? _occasion;
  Season? _season;

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _save(Recommendation rec, {required bool favourite}) async {
    var name = 'Suggested outfit';
    if (!favourite) {
      final entered = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: name);
          return AlertDialog(
            title: const Text('Save outfit'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Outfit name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
      if (entered == null || !mounted) return;
      name = entered;
    }
    try {
      await ref
          .read(recommendationRepositoryProvider)
          .saveAsOutfit(rec, name: name, favourite: favourite);
      ref.invalidate(recommendationsProvider);
      if (mounted) {
        _snack(favourite ? 'Saved to favourites' : 'Outfit saved');
      }
    } catch (e) {
      if (mounted) _snack('Could not save: $e');
    }
  }

  Future<void> _rate(Recommendation rec, int stars) async {
    await ref
        .read(recommendationRepositoryProvider)
        .recordFeedback(rec.fingerprint, FeedbackType.rated, rating: stars);
    ref.invalidate(recommendationsProvider);
    if (mounted) _snack('Rated $stars/5');
  }

  Future<void> _dismiss(Recommendation rec) async {
    final repo = ref.read(recommendationRepositoryProvider);
    await repo.recordFeedback(rec.fingerprint, FeedbackType.dismissed);
    ref.invalidate(recommendationsProvider);
    if (!mounted) return;
    _snack(
      'Recommendation dismissed',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () async {
          await repo.undoDismiss(rec.fingerprint);
          ref.invalidate(recommendationsProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(
      recommendationsProvider((occasion: _occasion, season: _season)),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                DropdownButton<Occasion?>(
                  value: _occasion,
                  hint: const Text('Any occasion'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Any occasion'),
                    ),
                    for (final o in Occasion.values)
                      DropdownMenuItem(value: o, child: Text(o.label)),
                  ],
                  onChanged: (v) => setState(() => _occasion = v),
                ),
                DropdownButton<Season?>(
                  value: _season,
                  hint: const Text('Any season'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Any season'),
                    ),
                    for (final s in Season.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  onChanged: (v) => setState(() => _season = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(e),
              data: (r) {
                if (r.recommendations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        r.emptyReason ?? 'No new suggestions right now',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: r.recommendations.length,
                  itemBuilder: (context, i) {
                    final rec = r.recommendations[i];
                    return RecommendationCard(
                      key: ValueKey(rec.fingerprint),
                      recommendation: rec,
                      saved: r.savedFingerprints.contains(rec.fingerprint),
                      onSave: () => _save(rec, favourite: false),
                      onFavourite: () => _save(rec, favourite: true),
                      onRate: (n) => _rate(rec, n),
                      onDismiss: () => _dismiss(rec),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
