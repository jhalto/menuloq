import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum AppImageSource { gallery, camera }

class PickedAppImage {
  const PickedAppImage({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

class ImagePickerException implements Exception {
  const ImagePickerException(this.message);

  final String message;
}

class ImagePickerHelper {
  ImagePickerHelper._();

  static final ImagePicker _picker = ImagePicker();

  static Future<PickedAppImage?> pick({
    required AppImageSource source,
    int maxBytes = 512 * 1024,
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 90,
  }) async {
    final file = await _picker.pickImage(
      source: source == AppImageSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      requestFullMetadata: false,
    );

    if (file == null) return null;

    final fileName = file.name;
    final extension = _extensionOf(fileName);

    if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
      throw const ImagePickerException(
        'Please select a PNG or JPG image.',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > maxBytes) {
      throw ImagePickerException(
        'Image must be smaller than ${maxBytes ~/ 1024} KB.',
      );
    }

    return PickedAppImage(bytes: bytes, fileName: fileName);
  }

  static Future<PickedAppImage?> pickFromGallery({
    int maxBytes = 512 * 1024,
  }) {
    return pick(source: AppImageSource.gallery, maxBytes: maxBytes);
  }

  static Future<PickedAppImage?> pickFromCamera({
    int maxBytes = 512 * 1024,
  }) {
    return pick(source: AppImageSource.camera, maxBytes: maxBytes);
  }

  static String _extensionOf(String fileName) {
    final separator = fileName.lastIndexOf('.');
    if (separator == -1) return '';
    return fileName.substring(separator + 1).toLowerCase();
  }
}
