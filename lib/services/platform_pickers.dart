import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Thin wrapper over platform pickers so tests can substitute a fake.
class PlatformPickers {
  const PlatformPickers();

  /// Opens the gallery / file dialog; returns the chosen file path or null.
  Future<String?> pickImagePath() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  /// Opens the gallery / file dialog allowing several photos; returns their
  /// paths (empty if cancelled).
  Future<List<String>> pickImagePaths() async {
    final files = await ImagePicker().pickMultiImage();
    return [for (final f in files) f.path];
  }

  /// Whether the device has a camera flow worth offering (phones only).
  bool get canTakePhoto => Platform.isAndroid;

  /// Opens the camera; returns the photo path or null if cancelled.
  Future<String?> takePhotoPath() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    return file?.path;
  }

  /// Cropping needs a native crop screen, which exists on Android only.
  bool get canCrop => Platform.isAndroid;

  /// Lets the user frame the garment; returns the cropped file's path, or
  /// null if they backed out.
  Future<String?> cropImage(String path) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop photo',
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );
    return cropped?.path;
  }

  static const _zipType = XTypeGroup(
    label: 'Wardrobe backup',
    extensions: ['zip'],
  );

  /// Asks where to save a backup; returns a path ending in .zip, or null if
  /// the user cancelled. (Desktop; see [exportsAsBytes] for Android.)
  Future<String?> chooseBackupSaveLocation(String suggestedName) async {
    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_zipType],
    );
    final path = location?.path;
    if (path == null) return null;
    return path.toLowerCase().endsWith('.zip') ? path : '$path.zip';
  }

  /// Android has no save dialog that returns a writable path, so the backup
  /// is built first and handed over as bytes.
  bool get exportsAsBytes => Platform.isAndroid;

  /// Saves [bytes] where the user chooses; returns false if cancelled.
  Future<bool> saveBackupBytes(String name, Uint8List bytes) async {
    final saved = await FilePicker.saveFile(
      fileName: name,
      bytes: bytes,
      mimeType: 'application/zip',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    return saved != null;
  }

  /// Asks the user to pick a backup file; null if cancelled.
  Future<String?> chooseBackupFile() async {
    final file = await openFile(acceptedTypeGroups: const [_zipType]);
    return file?.path;
  }

  /// Shows [path] in the system file manager (Windows only for now).
  Future<void> openFolder(String path) async {
    if (Platform.isWindows) await Process.run('explorer', [path]);
  }

  /// Whether [openFolder] does anything on this platform.
  bool get canOpenFolder => Platform.isWindows;
}
