import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper over platform pickers so tests can substitute a fake.
class PlatformPickers {
  const PlatformPickers();

  /// Opens the gallery / file dialog; returns the chosen file path or null.
  Future<String?> pickImagePath() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  static const _zipType = XTypeGroup(
    label: 'Wardrobe backup',
    extensions: ['zip'],
  );

  /// Asks where to save a backup; returns a path ending in .zip, or null if
  /// the user cancelled.
  Future<String?> chooseBackupSaveLocation(String suggestedName) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_zipType],
    );
    final path = location?.path;
    if (path == null) return null;
    return path.toLowerCase().endsWith('.zip') ? path : '$path.zip';
  }

  /// Asks the user to pick a backup file; null if cancelled.
  Future<String?> chooseBackupFile() async {
    final file = await openFile(acceptedTypeGroups: const [_zipType]);
    return file?.path;
  }
}
