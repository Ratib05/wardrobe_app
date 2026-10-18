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
    ]) {
      expect(dependencies.contains(name), isFalse, reason: name);
    }
  });

  test('the Android app asks for no network access and opts out of backup', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, isNot(contains('android.permission.INTERNET')));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules'));
  });
}
