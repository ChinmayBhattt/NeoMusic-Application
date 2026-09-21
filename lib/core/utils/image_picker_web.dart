// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

Future<String?> pickImagePlatform({
  int maxWidth = 800,
  int maxHeight = 600,
  double quality = 0.8,
}) async {
  final completer = Completer<String?>();
  final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((_) {
        final rawDataUrl = reader.result as String?;
        if (rawDataUrl == null) {
          completer.complete(null);
          return;
        }

        // Compress and downscale via offscreen canvas to avoid localStorage quota limits
        try {
          final img = html.ImageElement();
          img.src = rawDataUrl;
          img.onLoad.listen((_) {
            int width = img.width ?? 400;
            int height = img.height ?? 400;

            if (width > maxWidth || height > maxHeight) {
              final double ratioW = maxWidth / width;
              final double ratioH = maxHeight / height;
              final double ratio = ratioW < ratioH ? ratioW : ratioH;
              width = (width * ratio).round();
              height = (height * ratio).round();
            }

            final canvas = html.CanvasElement(width: width, height: height);
            final ctx = canvas.context2D;
            ctx.drawImageScaled(img, 0, 0, width, height);

            final compressed = canvas.toDataUrl('image/jpeg', quality);
            completer.complete(compressed);
          });
          img.onError.listen((_) {
            completer.complete(rawDataUrl);
          });
        } catch (_) {
          completer.complete(rawDataUrl);
        }
      });
      reader.onError.listen((_) {
        completer.complete(null);
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
