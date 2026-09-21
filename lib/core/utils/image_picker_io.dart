import 'dart:convert';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImagePlatform() async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    }
  } catch (_) {}
  return null;
}
