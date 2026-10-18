import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:path/path.dart' as p;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/widgets/page_header.dart';
import '../../services/backup_history.dart';
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

String _size(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

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

  Widget _card(String title, List<Widget> children) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );

  Widget _tile(String label, Widget value) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: monoCaption(context)),
          const SizedBox(height: 6),
          value,
        ],
      ),
    ),
  );

  Widget _recent(List<BackupRecord> records) {
    if (records.isEmpty) {
      return const Text(
        'No backups made yet.',
        style: TextStyle(color: AppColors.muted),
      );
    }
    return Column(
      children: [
        for (final r in records)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              r.kind == BackupKind.safetyCopy
                  ? Icons.shield_outlined
                  : Icons.inventory_2_outlined,
            ),
            title: Text(
              r.kind == BackupKind.safetyCopy
                  ? 'Safety copy · ${p.basename(r.path)}'
                  : p.basename(r.path),
            ),
            subtitle: Text(
              '${_date(r.createdAt)} · ${_size(r.sizeBytes)}'
              '${File(r.path).existsSync() ? '' : ' · File not found'}',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final paths = ref.watch(storagePathsProvider);
    final photos = ref.watch(photoStatusProvider);
    final stats = ref.watch(storageStatsProvider).value;
    final history = ref.watch(backupHistoryProvider).value ?? const [];
    final compact = MediaQuery.sizeOf(context).width < 640;
    final fileName = BackupController.suggestedFileName(DateTime.now());
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 40,
          compact ? 16 : 32,
          compact ? 16 : 40,
          32,
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(
                  eyebrow: 'Stored on this device',
                  title: 'Backup & restore',
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 4,
                  child: _busy ? const LinearProgressIndicator() : null,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 200,
                      child: _tile(
                        'Database',
                        Text(
                          stats == null ? '…' : _size(stats.database),
                          key: const Key('db-size'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: _tile(
                        'Photos',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats == null ? '…' : _size(stats.photos),
                              key: const Key('photos-size'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            photos.when(
                              data: (s) => Text(
                                '${_plural(s.total, 'photo')}, ${s.missing} missing',
                              ),
                              loading: () => const Text('Checking photos…'),
                              error: (e, _) =>
                                  Text("Couldn't check photos: $e"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: compact ? double.infinity : 440,
                      child: _tile(
                        'Location',
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(paths.root.path),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              key: const Key('open-folder'),
                              onPressed: () => ref
                                  .read(platformPickersProvider)
                                  .openFolder(paths.root.path),
                              icon: const Icon(Icons.folder_open, size: 18),
                              label: const Text('Open folder'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: compact ? double.infinity : 464,
                      child: _card('Export a backup', [
                        const Text(
                          'Keep backups somewhere other than this computer, '
                          'such as a USB drive.',
                        ),
                        const SizedBox(height: 12),
                        Text('SUGGESTED FILE', style: monoCaption(context)),
                        Text(fileName, key: const Key('suggested-file')),
                        const SizedBox(height: 8),
                        Text('APPROX. SIZE', style: monoCaption(context)),
                        Text(
                          stats == null
                              ? '…'
                              : _size(stats.database + stats.photos),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _busy ? null : _backup,
                          icon: const Icon(Icons.backup_outlined),
                          label: const Text('Back up wardrobe'),
                        ),
                      ]),
                    ),
                    SizedBox(
                      width: compact ? double.infinity : 464,
                      child: _card('Restore from a backup', [
                        const Text('Restoring replaces your current wardrobe.'),
                        const SizedBox(height: 8),
                        const Text(
                          'A safety copy of your current wardrobe is saved '
                          'first. If it cannot be saved, nothing is replaced.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _restore,
                          icon: const Icon(Icons.restore),
                          label: const Text('Restore wardrobe'),
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('RECENT BACKUPS', style: monoCaption(context)),
                const SizedBox(height: 8),
                _card('', [_recent(history)]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
