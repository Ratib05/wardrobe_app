import 'package:flutter/material.dart';

/// Shown for any AsyncValue.error. Errors are also logged locally.
class ErrorView extends StatelessWidget {
  ErrorView(this.error, {super.key}) {
    debugPrint('ErrorView: $error');
  }

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Something went wrong: $error', textAlign: TextAlign.center),
    ),
  );
}
