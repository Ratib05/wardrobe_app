import 'package:flutter/material.dart';

import '../theme.dart';

/// Page heading from the design: a small monospace eyebrow, a large bold
/// title and an optional block of actions on the right.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Phones (the bottom-bar layout) skip the eyebrow to save space.
    final showEyebrow = MediaQuery.sizeOf(context).width >= 600;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null && showEyebrow) ...[
          Text(eyebrow!.toUpperCase(), style: monoCaption(context)),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: compact ? 30 : 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ],
    );
    if (trailing == null) return heading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: 16),
        trailing!,
      ],
    );
  }
}
