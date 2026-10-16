import 'package:flutter/material.dart';

/// A wrap of chips for picking one or many values of an enum.
/// With [single], tapping the selected chip again clears the selection.
class EnumChips<T extends Enum> extends StatelessWidget {
  const EnumChips({
    super.key,
    required this.values,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.single = false,
  });

  final List<T> values;
  final String Function(T) label;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool single;

  void _toggle(T value) {
    if (single) {
      onChanged(selected.contains(value) ? <T>{} : {value});
    } else {
      onChanged(
        selected.contains(value)
            ? (Set<T>.of(selected)..remove(value))
            : (Set<T>.of(selected)..add(value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final v in values)
        FilterChip(
          label: Text(label(v)),
          selected: selected.contains(v),
          onSelected: (_) => _toggle(v),
        ),
    ],
  );
}
