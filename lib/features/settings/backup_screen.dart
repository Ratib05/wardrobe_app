import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../services/backup_service.dart';
import '../recommendations/recommendations_providers.dart';
import '../wardrobe/wardrobe_providers.dart';
import 'backup_controller.dart';

String _plural(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : (many ?? '${one}s')}';

String _describe(Map<String, int> counts) =>
    '${_plural(counts['clothingItems'] ?? 0, 'item')}, '
    '${_plural(counts['outfits'] ?? 0, 'outfit')} and '
    '${_plural(counts['wishlistItems'] ?? 0, 'wishlist entry', 'wishlist entries')}';

String _date(DateTime d) {
  final l = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  void _snack(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _message(String title, String body) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  /// Runs [action] with the UI locked and a progress bar showing.
  Future<void> _guarded(
    String failureTitle,
    Future<void> Function() action,
  ) async {
    setState(() => _busy = true);
    try {
      await action();
    } on BackupException catch (e) {
      if (mounted) await _message(failureTitle, e.message);
    } catch (e) {
      if (mounted) await _message(failureTitle, 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup() => _guarded('Backup failed', () async {
    final result = await ref.read(backupControllerProvider).backup();
    if (result == null || !mounted) return;
    _snack('Backup saved');
    if (result.missingImages.isNotEmpty) {
      await _message(
        'Some photos were not included',
        '${_plural(result.missingImages.length, 'photo')} could not be found '
            'on this device, so they are not in the backup.',
      );
    }
  });

  Future<void> _restore() => _guarded('Restore failed', () async {
    final controller = ref.read(backupControllerProvider);
    final staged = await controller.pickAndStage();
    if (staged == null || !mounted) return;
    final current = await controller.currentCounts();
    if (!mounted) return;
    final replace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace your wardrobe?'),
        content: Text(
          '${current == null ? "Your current wardrobe couldn't be read" : 'Your current ${_describe(current)}'} '
          'will be replaced by the backup from ${_date(staged.manifest.createdAt)} '
          '(${_describe(staged.counts)}).'
          '${staged.missingImages.isEmpty ? '' : '\n\n${_plural(staged.missingImages.length, 'photo')} in this backup are missing and will show as missing.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    if (replace != true) {
      await controller.cancelRestore(staged);
      return;
    }
    final restored = await controller.confirmRestore(staged);
    ref.invalidate(recommendationsProvider);
    if (mounted) _snack('Wardrobe restored: ${_describe(restored)}');
  });

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final paths = ref.watch(storagePathsProvider);
    final photos = ref.watch(photoStatusProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section('Backup', [
                const Text(
                  'Keep backups somewhere other than this computer, such as a '
                  'USB drive.',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _backup,
                    icon: const Icon(Icons.backup_outlined),
                    label: const Text('Back up wardrobe'),
                  ),
                ),
              ]),
              _section('Restore', [
                const Text('Restoring replaces your current wardrobe.'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore wardrobe'),
                  ),
                ),
              ]),
              _section('Storage', [
                const Text('Data folder'),
                SelectableText(paths.root.path),
                const SizedBox(height: 8),
                photos.when(
                  data: (s) => Text(
                    '${_plural(s.total, 'photo')}, ${s.missing} missing',
                  ),
                  loading: () => const Text('Checking photos…'),
                  error: (e, _) => Text("Couldn't check photos: $e"),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
