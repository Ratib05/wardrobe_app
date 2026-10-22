import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/widgets/error_view.dart';
import '../../app/widgets/page_header.dart';
import '../../core/clothing_item.dart';
import '../../core/wardrobe_values.dart';
import 'engine/recommendation_engine.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'recommendations_providers.dart';
import 'widgets/recommendation_card.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() =>
      _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  // Edited in the filter bar; applied when "Show suggestions" is pressed.
  RecommendationFilters _draft = noRecommendationFilters;
  RecommendationFilters _applied = noRecommendationFilters;

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
          .saveAsOutfit(
            rec,
            name: name,
            favourite: favourite,
            occasion: _applied.occasion,
            season: _applied.season,
          );
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

  Widget _filterBar(List<ClothingItem> items, {required bool compact}) {
    final choosable = [
      for (final i in items)
        if (i.isAvailable) i,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    Widget field<T>(
      String label,
      T value,
      List<DropdownMenuItem<T>> entries,
      ValueChanged<T?> onChanged,
    ) => SizedBox(
      width: 180,
      child: DropdownButtonFormField<T>(
        key: ValueKey('$label-$value'),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: entries,
        onChanged: onChanged,
      ),
    );
    const any = Text('Any');
    final bar = Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            field<Occasion?>(
              'Occasion',
              _draft.occasion,
              [
                const DropdownMenuItem(value: null, child: any),
                for (final o in Occasion.values)
                  DropdownMenuItem(value: o, child: Text(o.label)),
              ],
              (v) => setState(
                () => _draft = (
                  occasion: v,
                  season: _draft.season,
                  formality: _draft.formality,
                  mustIncludeId: _draft.mustIncludeId,
                ),
              ),
            ),
            field<Season?>(
              'Season',
              _draft.season,
              [
                const DropdownMenuItem(value: null, child: any),
                for (final s in Season.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              (v) => setState(
                () => _draft = (
                  occasion: _draft.occasion,
                  season: v,
                  formality: _draft.formality,
                  mustIncludeId: _draft.mustIncludeId,
                ),
              ),
            ),
            field<Formality?>(
              'Formality',
              _draft.formality,
              [
                const DropdownMenuItem(value: null, child: any),
                for (final f in Formality.values)
                  DropdownMenuItem(value: f, child: Text(f.label)),
              ],
              (v) => setState(
                () => _draft = (
                  occasion: _draft.occasion,
                  season: _draft.season,
                  formality: v,
                  mustIncludeId: _draft.mustIncludeId,
                ),
              ),
            ),
            field<String?>(
              'Must include',
              _draft.mustIncludeId,
              [
                const DropdownMenuItem(value: null, child: Text('Nothing')),
                for (final i in choosable)
                  DropdownMenuItem(
                    value: i.id,
                    child: Text(i.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              (v) => setState(
                () => _draft = (
                  occasion: _draft.occasion,
                  season: _draft.season,
                  formality: _draft.formality,
                  mustIncludeId: v,
                ),
              ),
            ),
            FilledButton(
              key: const Key('show-suggestions'),
              onPressed: () => setState(() => _applied = _draft),
              child: const Text('Show suggestions'),
            ),
          ],
        ),
      ),
    );
    if (!compact) return bar;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        key: const Key('filters-tile'),
        shape: const Border(),
        collapsedShape: const Border(),
        title: const Text('Filters'),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        children: [bar],
      ),
    );
  }

  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Phone layout: one suggestion per page, swipe or use the arrows.
  Widget _pager(RecommendationResults r) {
    final count = r.recommendations.length;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            key: const Key('suggestion-pager'),
            controller: _pageController,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final rec = r.recommendations[i];
              return SingleChildScrollView(
                child: RecommendationCard(
                  key: ValueKey(rec.fingerprint),
                  recommendation: rec,
                  rank: i + 1,
                  onSave: () => _save(rec, favourite: false),
                  onFavourite: () => _save(rec, favourite: true),
                  onRate: (n) => _rate(rec, n),
                  onDismiss: () => _dismiss(rec),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous suggestion',
              onPressed: _page > 0
                  ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    )
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${(_page + 1).clamp(1, count)} / $count',
              key: const Key('pager-position'),
              style: monoCaption(context),
            ),
            IconButton(
              tooltip: 'Next suggestion',
              onPressed: _page < count - 1
                  ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    )
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Scores use fixed rules and weights — no data leaves this device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(recommendationsProvider(_applied));
    final items = ref.watch(wardrobeItemsProvider(false)).value ?? const [];
    final total = results.value?.total ?? 0;
    final compact = MediaQuery.sizeOf(context).width < 640;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 40,
          compact ? 16 : 32,
          compact ? 16 : 40,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: results.hasValue && total > 0
                  ? 'Ranked from $total valid combination${total == 1 ? '' : 's'}'
                  : 'Suggestions',
              title: 'Suggested outfits',
              compact: compact,
            ),
            const SizedBox(height: 16),
            _filterBar(items, compact: compact),
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
                  if (compact) return _pager(r);
                  return ListView.builder(
                    itemCount: r.recommendations.length + 1,
                    itemBuilder: (context, i) {
                      if (i == r.recommendations.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Scores use fixed rules and weights — no data '
                            'leaves this device. Adjust weights in Settings › '
                            'Recommendations.',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        );
                      }
                      final rec = r.recommendations[i];
                      return RecommendationCard(
                        key: ValueKey(rec.fingerprint),
                        recommendation: rec,
                        rank: i + 1,
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
      ),
    );
  }
}
