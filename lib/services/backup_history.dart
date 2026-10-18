import 'dart:convert';
import 'dart:io';

enum BackupKind { backup, safetyCopy }

/// One backup (or automatic safety copy) made by this app.
class BackupRecord {
  const BackupRecord({
    required this.path,
    required this.sizeBytes,
    required this.createdAt,
    this.kind = BackupKind.backup,
  });

  final String path;
  final int sizeBytes;
  final DateTime createdAt;
  final BackupKind kind;

  Map<String, Object?> toJson() => {
    'path': path,
    'sizeBytes': sizeBytes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'kind': kind.name,
  };

  static BackupRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final path = json['path'];
    final size = json['sizeBytes'];
    final created = DateTime.tryParse('${json['createdAt']}');
    if (path is! String || size is! int || created == null) return null;
    return BackupRecord(
      path: path,
      sizeBytes: size,
      createdAt: created,
      kind:
          BackupKind.values.asNameMap()['${json['kind']}'] ?? BackupKind.backup,
    );
  }
}

/// Small JSON log of backups made on this device (newest first), so the app
/// can show "Last backup 3 days ago" and a recent-backups list. A missing or
/// damaged file simply reads as empty. Synchronous I/O: the file is tiny.
class BackupHistory {
  BackupHistory(this.file);

  final File file;

  static const _maxRecords = 20;

  List<BackupRecord> load() {
    try {
      if (!file.existsSync()) return const [];
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! List) return const [];
      return [for (final e in decoded) ?BackupRecord.fromJson(e)]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on FormatException {
      return const [];
    } on FileSystemException {
      return const [];
    }
  }

  void add(BackupRecord record) => _write([record, ...load()]);

  /// Forgets the record for [path] (used when an old safety copy is deleted).
  void remove(String path) => _write([
    for (final r in load())
      if (r.path != path) r,
  ]);

  void _write(List<BackupRecord> all) {
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final kept = all.take(_maxRecords).map((r) => r.toJson()).toList();
    final tmp = File('${file.path}.tmp');
    tmp.writeAsStringSync(jsonEncode(kept));
    tmp.renameSync(file.path);
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Last backup today / yesterday / 3 days ago / 2 Sep 2026", or
/// "No backup yet". Safety copies do not count as backups.
String lastBackupLabel(List<BackupRecord> records, DateTime now) {
  final backups = records.where((r) => r.kind == BackupKind.backup);
  if (backups.isEmpty) return 'No backup yet';
  final last = backups.first.createdAt.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(last.year, last.month, last.day);
  final days = today.difference(day).inDays;
  if (days <= 0) return 'Last backup today';
  if (days == 1) return 'Last backup yesterday';
  if (days < 30) return 'Last backup $days days ago';
  return 'Last backup ${last.day} ${_months[last.month - 1]} ${last.year}';
}
