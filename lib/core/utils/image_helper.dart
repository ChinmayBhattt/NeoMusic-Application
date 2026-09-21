import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  static ImageProvider? getImageProvider(String? url) {
    if (url == null || url.trim().isEmpty) return null;

    final trimmed = url.trim();
    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        if (commaIndex != -1) {
          final base64String = trimmed.substring(commaIndex + 1);
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        }
      } catch (_) {
        return null;
      }
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return CachedNetworkImageProvider(trimmed);
    }

    return null;
  }
}
