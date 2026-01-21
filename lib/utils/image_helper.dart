import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Retourne un ImageProvider à partir d'un animal
  /// Priorité: base64 > photoPath > null
  static ImageProvider? getAnimalImageProvider(String? photoBase64, String? photoPath) {
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(photoBase64);
        return MemoryImage(bytes);
      } catch (e) {
        // Si le décodage échoue, essayer photoPath
      }
    }
    
    if (photoPath != null && photoPath.isNotEmpty) {
      return AssetImage(photoPath);
    }
    
    return null;
  }

  /// Widget pour afficher l'image d'un animal avec fallback
  static Widget buildAnimalImage({
    String? photoBase64,
    String? photoPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final imageProvider = getAnimalImageProvider(photoBase64, photoPath);
    
    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: fit,
      );
    }
    
    return placeholder ?? const SizedBox.shrink();
  }
}
