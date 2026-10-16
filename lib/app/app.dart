import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

class WardrobeApp extends StatefulWidget {
  const WardrobeApp({super.key});

  @override
  State<WardrobeApp> createState() => _WardrobeAppState();
}

class _WardrobeAppState extends State<WardrobeApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Wardrobe',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    routerConfig: _router,
  );
}
