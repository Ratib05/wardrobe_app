import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app must work fully offline and send nothing anywhere. This guards the
/// project restrictions (no cloud, analytics, backend or AI services).
void main() {
  const forbidden = [
    'package:http/',
    'package:dio/',
    'dart:html',
    'HttpClient',
    'WebSocket',
    'Socket.connect',
    'firebase',
    'supabase',
    'sentry',
    'crashlytics',
    'analytics',
    'openai',
    'anthropic',
  ];

  test('app code contains no network, cloud or analytics usage', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.endsWith('.g.dart')) continue;
      final text = file.readAsStringSync().toLowerCase();
      for (final token in forbidden) {
        if (text.contains(token.toLowerCase())) {
          offenders.add('${file.path}: $token');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('pubspec has no cloud, analytics or networking dependencies', () {
    final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
    final dependencies = pubspec.split('dev_dependencies:').first;
    for (final name in [
      'http:',
      'dio:',
      'firebase',
      'supabase',
      'sentry',
      'crashlytics',
      'analytics',
      'image_cropper:', // not supported on Windows; Android-only if ever added
    ]) {
      expect(dependencies.contains(name), isFalse, reason: name);
    }
  });
}
