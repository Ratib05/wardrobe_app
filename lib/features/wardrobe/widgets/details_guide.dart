import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/wardrobe_values.dart';

/// A plain-English list of every formality level and style.
Future<void> showDetailsGuide(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('What do these mean?'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Heading('Formality, least to most dressy'),
            for (final f in Formality.values) _Entry(f.label, f.guide),
            const SizedBox(height: 12),
            const _Heading('Style'),
            for (final s in StyleTag.values) _Entry(s.label, s.guide),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: monoCaption(context)),
  );
}

class _Entry extends StatelessWidget {
  const _Entry(this.label, this.guide);

  final String label;
  final String guide;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: guide),
        ],
      ),
    ),
  );
}
