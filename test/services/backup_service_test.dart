import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:wardrobe_app/core/wardrobe_values.dart';
import 'package:wardrobe_app/database/app_database.dart';
import 'package:wardrobe_app/services/backup_service.dart';
import 'package:wardrobe_app/services/storage_paths.dart';

import '../helpers.dart';

/// A source wardrobe: two items (one photo present, one missing), an outfit
/// and a wishlist entry, on disk under [paths].
class Source {
  Source(this.paths, this.db);
  final StoragePaths paths;
  final AppDatabase db;
}

Future<Source> makeSource() async {
  final paths = await tempPaths();
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  File(
    p.join(paths.clothingImagesDir.path, 'a.jpg'),
  ).writeAsBytesSync(jpegBytes());
  await db.clothingDao.upsert(
    item(id: 'a', name: 'With photo', imagePath: 'images/clothing/a.jpg'),
  );
  await db.clothingDao.upsert(
    item(id: 'b', name: 'Lost photo', imagePath: 'images/clothing/gone.jpg'),
  );
  await db.outfitDao.saveOutfit(
    OutfitsCompanion(
      id: const Value('o1'),
      name: const Value('Outfit'),
      createdAt: Value(DateTime.utc(2026)),
      updatedAt: Value(DateTime.utc(2026)),
    ),
    ['a', 'b'],
  );
  await db.wishlistDao.upsert(
    WishlistItemsCompanion.insert(
      id: 'w1',
      name: 'Boots',
      category: ClothingCategory.footwear,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );
  return Source(paths, db);
}

Future<String> backupOf(Source s) async {
  final dest = p.join(
    Directory.systemTemp.createTempSync('wardrobe_dest_').path,
    'backup.zip',
  );
  await BackupService(s.paths, appVersion: '1.0.0+1').createBackup(s.db, dest);
  return dest;
}

/// Copies [src] to [dest] with entries replaced, removed or added.
void rewriteZip(
  String src,
  String dest, {
  Map<String, List<int>> replace = const {},
  Set<String> remove = const {},
  Map<String, List<int>> add = const {},
}) {
  final original = ZipDecoder().decodeBytes(File(src).readAsBytesSync());
  final out = Archive();
  for (final f in original.files) {
    if (remove.contains(f.name) || !f.isFile) continue;
    out.addFile(ArchiveFile.bytes(f.name, replace[f.name] ?? f.content));
  }
  add.forEach((name, bytes) => out.addFile(ArchiveFile.bytes(name, bytes)));
  File(dest).writeAsBytesSync(ZipEncoder().encodeBytes(out));
}

Map<String, Object?> manifestOf(String zip) {
  final a = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
  return jsonDecode(utf8.decode(a.findFile('manifest.json')!.content))
      as Map<String, Object?>;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('createBackup', () {
    test('contains manifest, snapshot and present photos only', () async {
      final s = await makeSource();
      final zip = await backupOf(s);
      final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
      final names = archive.files.where((f) => f.isFile).map((f) => f.name);
      expect(names.toSet(), {
        'manifest.json',
        'database/wardrobe.db',
        'images/clothing/a.jpg',
      });
      final manifest = BackupManifest.fromJson(manifestOf(zip));
      expect(manifest.counts, {
        'clothingItems': 2,
        'outfits': 1,
        'wishlistItems': 1,
      });
      expect(manifest.schemaVersion, 2);
      expect(manifest.images, ['images/clothing/a.jpg']);
    });

    test(
      'reports missing photos and the snapshot is a valid database',
      () async {
        final s = await makeSource();
        final dest = p.join(
          Directory.systemTemp.createTempSync('d_').path,
          'b.zip',
        );
        final result = await BackupService(
          s.paths,
          appVersion: '1.0.0+1',
        ).createBackup(s.db, dest);
        expect(result.missingImages, ['images/clothing/gone.jpg']);

        final archive = ZipDecoder().decodeBytes(File(dest).readAsBytesSync());
        final snapshot = File(p.join(s.paths.tempDir.path, 'snap.db'))
          ..writeAsBytesSync(archive.findFile('database/wardrobe.db')!.content);
        final raw = sqlite.sqlite3.open(snapshot.path);
        addTearDown(raw.close);
        expect(raw.select('PRAGMA user_version').first.values.first, 2);
        expect(
          raw.select('SELECT COUNT(*) FROM clothing_items').first.values.first,
          2,
        );
      },
    );

    test(
      'a tampered image path is reported missing and never zipped',
      () async {
        final s = await makeSource();
        await s.db.clothingDao.upsert(
          item(id: 'evil', imagePath: '../data/wardrobe.db'),
        );
        final zip = await backupOf(s);
        final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
        expect(archive.files.any((f) => f.name.contains('..')), isFalse);
        expect(
          archive.files.where((f) => f.isFile).map((f) => f.name),
          isNot(contains('data/wardrobe.db')),
        );
      },
    );

    test('unwritable destination fails cleanly', () async {
      final s = await makeSource();
      final dest = p.join(s.paths.root.path, 'no_such_folder', 'b.zip');
      await expectLater(
        BackupService(s.paths, appVersion: '1').createBackup(s.db, dest),
        throwsA(
          isA<BackupException>().having(
            (e) => e.error,
            'error',
            BackupError.ioFailure,
          ),
        ),
      );
      expect(File(dest).existsSync(), isFalse);
      expect(s.paths.tempDir.listSync(), isEmpty);
    });

    test('manifest round trip and validation', () {
      final m = BackupManifest(
        formatVersion: 1,
        appVersion: '1.0.0',
        schemaVersion: 1,
        createdAt: DateTime.utc(2026, 1, 2),
        counts: const {'clothingItems': 3},
        images: const ['images/clothing/x.jpg'],
      );
      final back = BackupManifest.fromJson(m.toJson());
      expect(back.counts, m.counts);
      expect(back.createdAt, m.createdAt);
      expect(back.images, m.images);
      final broken = m.toJson()..remove('schemaVersion');
      expect(() => BackupManifest.fromJson(broken), throwsFormatException);
    });
  });

  group('restore', () {
    late Source source;
    late String zip;
    late StoragePaths target;
    late Uint8List liveDbBytes;
    late BackupService service;

    setUp(() async {
      source = await makeSource();
      zip = await backupOf(source);
      target = await tempPaths();
      // A live wardrobe in the target that must survive any failed restore.
      final live = AppDatabase(NativeDatabase(target.databaseFile));
      await live.clothingDao.upsert(item(id: 'live', name: 'Live item'));
      await live.close();
      File(
        p.join(target.clothingImagesDir.path, 'live.jpg'),
      ).writeAsBytesSync(jpegBytes());
      liveDbBytes = target.databaseFile.readAsBytesSync();
      service = BackupService(target, appVersion: '1.0.0+1');
    });

    void expectLiveUntouched() {
      expect(target.databaseFile.readAsBytesSync(), liveDbBytes);
      expect(
        File(p.join(target.clothingImagesDir.path, 'live.jpg')).existsSync(),
        isTrue,
      );
      expect(
        target.tempDir.listSync().where(
          (e) =>
              p.basename(e.path).startsWith('restore-') ||
              p.basename(e.path).startsWith('pre-restore-'),
        ),
        isEmpty,
      );
    }

    Future<void> expectRejected(String path, BackupError error) async {
      await expectLater(
        service.stageRestore(path, currentSchemaVersion: 2),
        throwsA(isA<BackupException>().having((e) => e.error, 'error', error)),
      );
      expectLiveUntouched();
    }

    test('round trip restores records, links and photos', () async {
      final staged = await service.stageRestore(zip, currentSchemaVersion: 2);
      expect(staged.counts, {
        'clothingItems': 2,
        'outfits': 1,
        'wishlistItems': 1,
      });
      expect(staged.missingImages, ['images/clothing/gone.jpg']);
      await service.applyRestore(staged);

      final restored = AppDatabase(NativeDatabase(target.databaseFile));
      addTearDown(restored.close);
      final items = await restored.select(restored.clothingItems).get();
      expect(items.map((i) => i.id).toSet(), {'a', 'b'});
      expect(await restored.select(restored.outfitItems).get(), hasLength(2));
      expect(await restored.select(restored.wishlistItems).get(), hasLength(1));
      expect(target.imageFile('images/clothing/a.jpg').existsSync(), isTrue);
      expect(
        target.imageFile('images/clothing/live.jpg').existsSync(),
        isFalse,
      );
      expect(target.tempDir.listSync(), isEmpty);
    });

    test('a non-zip file is not a backup', () async {
      final f = File(p.join(target.root.path, 'notes.zip'))
        ..writeAsStringSync('hello');
      await expectRejected(f.path, BackupError.notABackup);
    });

    test('a zip without a manifest is not a backup', () async {
      final out = p.join(target.root.path, 'nomanifest.zip');
      rewriteZip(zip, out, remove: {'manifest.json'});
      await expectRejected(out, BackupError.notABackup);
    });

    test('an unknown format version is rejected', () async {
      final out = p.join(target.root.path, 'v2.zip');
      final m = manifestOf(zip)..['formatVersion'] = 2;
      rewriteZip(
        zip,
        out,
        replace: {'manifest.json': utf8.encode(jsonEncode(m))},
      );
      await expectRejected(out, BackupError.unsupportedVersion);
    });

    test('a newer schema is rejected', () async {
      final out = p.join(target.root.path, 'newer.zip');
      final m = manifestOf(zip)..['schemaVersion'] = 99;
      rewriteZip(
        zip,
        out,
        replace: {'manifest.json': utf8.encode(jsonEncode(m))},
      );
      await expectRejected(out, BackupError.newerSchema);
    });

    test(
      'the manifest carries SHA-256 checksums of the database and photos',
      () {
        final m = manifestOf(zip);
        final sums = (m['checksums'] as Map).cast<String, String>();
        expect(
          sums.keys,
          containsAll(['database/wardrobe.db', 'images/clothing/a.jpg']),
        );
        final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
        final photo =
            archive.findFile('images/clothing/a.jpg')!.content as List<int>;
        expect(sums['images/clothing/a.jpg'], sha256.convert(photo).toString());
      },
    );

    test('a photo that no longer matches its checksum is rejected', () async {
      final out = p.join(target.root.path, 'tampered.zip');
      rewriteZip(
        zip,
        out,
        replace: {
          'images/clothing/a.jpg': [1, 2, 3],
        },
      );
      await expectRejected(out, BackupError.corruptDatabase);
    });

    test('a backup without checksums still restores', () async {
      final out = p.join(target.root.path, 'old.zip');
      final manifest = manifestOf(zip)..remove('checksums');
      rewriteZip(
        zip,
        out,
        replace: {'manifest.json': utf8.encode(jsonEncode(manifest))},
      );
      final staged = await service.stageRestore(out, currentSchemaVersion: 2);
      expect(staged.manifest.checksums, isEmpty);
      await service.discard(staged);
    });

    test('a damaged database is rejected', () async {
      final out = p.join(target.root.path, 'bad.zip');
      final archive = ZipDecoder().decodeBytes(File(zip).readAsBytesSync());
      final db = archive.findFile('database/wardrobe.db')!.content as List<int>;
      rewriteZip(
        zip,
        out,
        replace: {'database/wardrobe.db': db.sublist(0, 100)},
      );
      await expectRejected(out, BackupError.corruptDatabase);
    });

    test('entries that escape the staging folder are not written', () async {
      final out = p.join(target.root.path, 'evil.zip');
      rewriteZip(zip, out, add: {'../evil.txt': utf8.encode('x')});
      final staged = await service.stageRestore(out, currentSchemaVersion: 2);
      expect(
        File(p.join(target.tempDir.path, 'evil.txt')).existsSync(),
        isFalse,
      );
      expect(File(p.join(target.root.path, 'evil.txt')).existsSync(), isFalse);
      await service.discard(staged);
    });

    test('a failed apply keeps the existing wardrobe', () async {
      final staged = await service.stageRestore(zip, currentSchemaVersion: 2);
      Directory(
        p.join(staged.dir.path, 'database'),
      ).deleteSync(recursive: true);
      await expectLater(
        service.applyRestore(staged),
        throwsA(
          isA<BackupException>()
              .having((e) => e.error, 'error', BackupError.ioFailure)
              .having(
                (e) => e.message,
                'message',
                'Restore failed. Your existing wardrobe was kept.',
              ),
        ),
      );
      expectLiveUntouched();
    });

    test('discard removes the staging folder', () async {
      final staged = await service.stageRestore(zip, currentSchemaVersion: 2);
      await service.discard(staged);
      expect(staged.dir.existsSync(), isFalse);
      expectLiveUntouched();
    });
  });
}
