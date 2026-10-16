import 'package:image_picker/image_picker.dart';

/// Thin wrapper over platform pickers so tests can substitute a fake.
class PlatformPickers {
  const PlatformPickers();

  /// Opens the gallery / file dialog; returns the chosen file path or null.
  Future<String?> pickImagePath() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    return file?.path;
  }
}
