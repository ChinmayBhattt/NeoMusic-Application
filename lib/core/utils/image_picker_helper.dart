import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart'
    if (dart.library.io) 'image_picker_io.dart';

class ProfileImagePicker {
  static Future<String?> pickImage({
    int maxWidth = 800,
    int maxHeight = 600,
    double quality = 0.8,
  }) async {
    return pickImagePlatform(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    );
  }
}
