import 'dart:convert';
import 'package:image_picker/image_picker.dart';

Future<String?> pickImagePlatform({
  int maxWidth = 800,
  int maxHeight = 600,
  double quality = 0.8,
}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: (quality * 100).round(),
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';
      return 'data:$mime;base64,${base64Encode(bytes)}';
    }
  } catch (_) {}
  return null;
}
