import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickFromCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      return null;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  Future<File?> pickFromGallery() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!status.isGranted && !status.isLimited) {
      return null;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }
}