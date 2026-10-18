import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/colour_match.dart';
import '../../../core/wardrobe_values.dart';
import '../../../services/photo_colours.dart';

typedef IdentifiedColour = ({WardrobeColour colour, bool asMain});

/// Tap anywhere on the photo to see the name of the colour under your finger.
/// Pops an [IdentifiedColour] or null.
class IdentifyColourDialog extends StatefulWidget {
  const IdentifyColourDialog({
    super.key,
    required this.photo,
    required this.pixels,
  });

  final File photo;
  final PhotoPixels pixels;

  @override
  State<IdentifyColourDialog> createState() => _IdentifyColourDialogState();
}

class _IdentifyColourDialogState extends State<IdentifyColourDialog> {
  Offset? _tap; // 0–1 fractions of the photo
  List<ColourMatch> _matches = const [];

  void _onTap(Offset local, Size size) {
    final fx = (local.dx / size.width).clamp(0.0, 1.0);
    final fy = (local.dy / size.height).clamp(0.0, 1.0);
    setState(() {
      _tap = Offset(fx, fy);
      _matches = closestColours(widget.pixels.averageAt(fx, fy));
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pixels;
    final best = _matches.isEmpty ? null : _matches.first.colour;
    final other = alternativeTo(_matches);
    final maxPhotoHeight = MediaQuery.sizeOf(context).height * 0.45;
    return AlertDialog(
      title: const Text('What colour is this?'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxPhotoHeight),
                child: AspectRatio(
                  aspectRatio: p.width / p.height,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final size = box.biggest;
                      final tap = _tap;
                      return GestureDetector(
                        key: const Key('identify-photo'),
                        onTapDown: (d) => _onTap(d.localPosition, size),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(widget.photo, fit: BoxFit.fill),
                            if (tap != null)
                              Positioned(
                                left: tap.dx * size.width - 12,
                                top: tap.dy * size.height - 12,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (best == null)
                const Text(
                  'Tap the photo to find out.',
                  style: TextStyle(color: AppColors.muted),
                )
              else ...[
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(best.argb),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      best.label,
                      key: const Key('identified-colour'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (other != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Could also be: ${other.label}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
        OutlinedButton(
          key: const Key('identify-add'),
          onPressed: best == null
              ? null
              : () => Navigator.pop(context, (colour: best, asMain: false)),
          child: const Text('Add colour'),
        ),
        FilledButton(
          key: const Key('identify-main'),
          onPressed: best == null
              ? null
              : () => Navigator.pop(context, (colour: best, asMain: true)),
          child: const Text('Use as main colour'),
        ),
      ],
    );
  }
}
