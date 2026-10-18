import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/app_exceptions.dart';
import '../recommendations/engine/scoring.dart';
import '../recommendations/recommendations_providers.dart';

const _labels = {
  ScoreFactor.colour: 'Colour harmony',
  ScoreFactor.occasion: 'Occasion',
  ScoreFactor.formality: 'Formality',
  ScoreFactor.style: 'Style',
  ScoreFactor.season: 'Season',
  ScoreFactor.preferences: 'Your preferences',
  ScoreFactor.feedback: 'Past feedback',
};

/// Sliders for how much each factor counts towards an outfit's score.
/// Values are relative; they are shown (and used) as shares of 100.
class ScoreWeightsCard extends ConsumerStatefulWidget {
  const ScoreWeightsCard({super.key});

  @override
  ConsumerState<ScoreWeightsCard> createState() => _ScoreWeightsCardState();
}

class _ScoreWeightsCardState extends ConsumerState<ScoreWeightsCard> {
  // Raw slider values (0–100) while editing; null when nothing was touched.
  Map<ScoreFactor, double>? _draft;

  Map<ScoreFactor, double> _stored() {
    final weights = ref.read(scoreWeightsProvider).value;
    return {
      for (final f in ScoreFactor.values)
        f: (weights?[f] ?? f.defaultWeight) * 100,
    };
  }

  Future<void> _save() async {
    try {
      await ref.read(recommendationRepositoryProvider).setWeights(_draft!);
      ref.invalidate(recommendationsProvider);
      if (mounted) setState(() => _draft = null);
    } on ValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _reset() async {
    await ref.read(recommendationRepositoryProvider).resetWeights();
    ref.invalidate(recommendationsProvider);
    if (mounted) setState(() => _draft = null);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(scoreWeightsProvider); // rebuild when stored weights change
    final values = _draft ?? _stored();
    final total = values.values.fold(0.0, (a, b) => a + b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SCORE WEIGHTS', style: monoCaption(context)),
            const SizedBox(height: 4),
            const Text(
              'How much each factor counts towards an outfit’s score. '
              'Shares are rescaled so they add up to 100.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            for (final f in ScoreFactor.values)
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width < 640 ? 96 : 140,
                    child: Text(_labels[f]!, maxLines: 2),
                  ),
                  Expanded(
                    child: Slider(
                      key: Key('weight-${f.name}'),
                      value: values[f]!.clamp(0, 100),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (v) =>
                          setState(() => _draft = {...values, f: v}),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      total == 0
                          ? '0'
                          : '${(values[f]! / total * 100).round()}',
                      key: Key('share-${f.name}'),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const Key('save-weights'),
                  onPressed: _draft == null ? null : _save,
                  child: const Text('Save weights'),
                ),
                OutlinedButton(
                  key: const Key('reset-weights'),
                  onPressed: _reset,
                  child: const Text('Reset to defaults'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
