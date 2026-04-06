import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final appImagePickerProvider = Provider<AppImagePicker>((ref) {
  return AppImagePicker();
});

class AppImagePicker {
  AppImagePicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
    double? maxWidth,
    double? maxHeight,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final recoveredImage = await retrieveLostImage();
    if (recoveredImage != null) {
      return recoveredImage;
    }

    return _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      preferredCameraDevice: preferredCameraDevice,
    );
  }

  Future<XFile?> retrieveLostImage() async {
    final lostData = await _picker.retrieveLostData();
    if (lostData.isEmpty) {
      return null;
    }

    if (lostData.exception != null) {
      final message = lostData.exception!.message;
      throw Exception(
        message == null || message.isEmpty
            ? 'Unable to recover the selected image.'
            : message,
      );
    }

    final recoveredFiles = lostData.files;
    if (recoveredFiles != null && recoveredFiles.isNotEmpty) {
      return recoveredFiles.first;
    }

    return lostData.file;
  }
}
