import 'package:flutter/material.dart';

import '../theme.dart';

/// A filter pill with a small count: "Tops 4".
class CountChip extends StatelessWidget {
  const CountChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.text;
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.text,
      side: BorderSide(color: selected ? AppColors.text : AppColors.border),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: fg.withValues(alpha: 0.7),
              fontSize: 11,
              fontFamily: monoFamily,
              fontFamilyFallback: monoFallback,
            ),
          ),
        ],
      ),
    );
  }
}
