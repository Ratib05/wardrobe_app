import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.tune),
          title: const Text('Recommendation preferences'),
          subtitle: const Text('Colours and styles you like or want to avoid'),
          onTap: () => context.push('/settings/preferences'),
        ),
      ],
    ),
  );
}
